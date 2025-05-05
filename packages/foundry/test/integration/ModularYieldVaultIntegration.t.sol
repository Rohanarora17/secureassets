// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/vaults/ModularYieldVault.sol";
import "../../contracts/adapters/AaveV3Adapter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockAavePool.sol";
import "../mocks/MockAaveProtocolDataProvider.sol";


contract ModularYieldVaultIntegrationTest is Test {
    ModularYieldVault public vault;
    AaveV3Adapter public adapter;
    MockERC20 public mockAsset;
    MockERC20 public mockAToken;
    MockAavePool public mockAavePool;
    MockAaveProtocolDataProvider public mockDataProvider;
    
    address public owner;
    address public user;
    uint256 public constant TEST_AMOUNT = 1000 * 1e6; // 1000 USDC (6 decimals)
    uint256 public constant APY_RAY = 3e27; // 3% APY in ray (10^27)
    
    function setUp() public {
        // Set up test accounts
        owner = makeAddr("owner");
        user = makeAddr("user");
        
        // Deploy mock contracts
        mockAsset = new MockERC20("Mock USDC", "mUSDC", 6);
        mockAToken = new MockERC20("Mock aUSDC", "maUSDC", 6);
        mockAavePool = new MockAavePool();
        mockDataProvider = new MockAaveProtocolDataProvider();
        
        // Configure mock Aave
        mockAavePool.addAsset(address(mockAsset), address(mockAToken), APY_RAY);
        mockDataProvider.setTokenAddresses(
            address(mockAsset),
            address(mockAToken),
            address(0), // stableDebtToken
            address(0)  // variableDebtToken
        );
        mockDataProvider.setLiquidityRate(address(mockAsset), APY_RAY);
        
        // Deploy adapter
        vm.startPrank(owner);
        adapter = new AaveV3Adapter(address(mockAavePool), address(mockDataProvider));
        
        // Deploy vault
        vault = new ModularYieldVault(
            address(mockAsset),
            "USDC Yield Vault",
            "vUSDC",
            address(adapter)
        );
        vm.stopPrank();
        
        // Give user some tokens
        mockAsset.mint(user, TEST_AMOUNT);
        // Give pool some tokens for withdrawals
        mockAsset.mint(address(mockAavePool), TEST_AMOUNT * 2);
    }
    
    function testInitialState() public view {
        assertEq(vault.name(), "USDC Yield Vault");
        assertEq(vault.symbol(), "vUSDC");
        assertEq(address(vault.asset()), address(mockAsset));
        assertEq(address(vault.protocolAdapter()), address(adapter));
        assertEq(vault.minIdleAssets(), 1e16);
        assertFalse(vault.depositsPaused());
    }
    
    function testDepositAndWithdraw() public {
        vm.startPrank(user);
        
        // Approve vault to spend tokens
        mockAsset.approve(address(vault), TEST_AMOUNT);
        
        // Get initial balances
        uint256 initialAssetBalance = mockAsset.balanceOf(user);
        uint256 initialVaultBalance = vault.balanceOf(user);
        
        // Deposit
        uint256 shares = vault.deposit(TEST_AMOUNT, user);
        assertEq(shares, TEST_AMOUNT); // 1:1 ratio initially
        
        // Check balances after deposit
        assertEq(mockAsset.balanceOf(user), initialAssetBalance - TEST_AMOUNT);
        assertEq(vault.balanceOf(user), initialVaultBalance + shares);
        
        // Get aToken address and approve adapter to spend aTokens
        address aToken = adapter.getDepositToken(address(mockAsset));
        IERC20(aToken).approve(address(adapter), TEST_AMOUNT);
        
        // Withdraw half
        uint256 withdrawAmount = TEST_AMOUNT / 2;
        uint256 assets = vault.withdraw(withdrawAmount, user, user);
        assertEq(assets, withdrawAmount);
        
        // Check balances after withdrawal
        assertEq(mockAsset.balanceOf(user), initialAssetBalance - withdrawAmount);
        assertEq(vault.balanceOf(user), initialVaultBalance + shares - withdrawAmount);
        
        vm.stopPrank();
    }
    
    function testSetMinIdleAssets() public {
        uint256 newMinIdle = 2e16;
        vm.prank(owner);
        vault.setMinIdleAssets(newMinIdle);
        assertEq(vault.minIdleAssets(), newMinIdle);
    }
    
    function testSetDepositsPaused() public {
        vm.prank(owner);
        vault.setDepositsPaused(true);
        assertTrue(vault.depositsPaused());
        
        vm.prank(owner);
        vault.setDepositsPaused(false);
        assertFalse(vault.depositsPaused());
    }
    
    function test_RevertWhen_DepositWhenPaused() public {
        vm.prank(owner);
        vault.setDepositsPaused(true);
        
        vm.startPrank(user);
        mockAsset.approve(address(vault), TEST_AMOUNT);
        vm.expectRevert("Deposits are paused");
        vault.deposit(TEST_AMOUNT, user);
        vm.stopPrank();
    }
    
    function testGetAPY() public {
        // First deposit some tokens to ensure the adapter is initialized
        vm.startPrank(user);
        mockAsset.approve(address(vault), TEST_AMOUNT);
        vault.deposit(TEST_AMOUNT, user);
        vm.stopPrank();
        
        uint256 apy = vault.getAPY();
        assertEq(apy, 300); // 3% APY = 300 basis points
    }
    
    function testTotalAssets() public {
        vm.startPrank(user);
        mockAsset.approve(address(vault), TEST_AMOUNT);
        vault.deposit(TEST_AMOUNT, user);
        vm.stopPrank();
        
        assertEq(vault.totalAssets(), TEST_AMOUNT);
    }
    
    function test_RevertWhen_DepositZeroAmount() public {
        vm.startPrank(user);
        mockAsset.approve(address(vault), 0);
        vm.expectRevert("Amount must be greater than 0");
        vault.deposit(0, user);
        vm.stopPrank();
    }
    
    function test_RevertWhen_WithdrawZeroAmount() public {
        vm.startPrank(user);
        vm.expectRevert("Amount must be greater than 0");
        vault.withdraw(0, user, user);
        vm.stopPrank();
    }
    
    function test_RevertWhen_WithdrawMoreThanBalance() public {
        vm.startPrank(user);
        mockAsset.approve(address(vault), TEST_AMOUNT);
        vault.deposit(TEST_AMOUNT, user);
        bytes memory expectedError = abi.encodeWithSignature(
            "ERC4626ExceededMaxWithdraw(address,uint256,uint256)",
            user,
            TEST_AMOUNT + 1,
            TEST_AMOUNT
        );
        vm.expectRevert(expectedError);
        vault.withdraw(TEST_AMOUNT + 1, user, user);
        vm.stopPrank();
    }
}
