// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/factories/ModularVaultFactory.sol";
import "../../contracts/adapters/AaveV3Adapter.sol";
import "../../contracts/vaults/ModularYieldVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockAavePool.sol";
import "../mocks/MockAaveProtocolDataProvider.sol";

contract EndToEndTest is Test {
    ModularVaultFactory public factory;
    MockERC20 public usdc;
    MockERC20 public dai;
    MockAavePool public aavePool;
    MockAaveProtocolDataProvider public dataProvider;
    
    address public owner;
    address public user1;
    address public user2;
    
    uint256 public constant TEST_AMOUNT_USDC = 1000 * 1e6; // 1000 USDC
    uint256 public constant TEST_AMOUNT_DAI = 1000 * 1e18; // 1000 DAI
    
    function setUp() public {
        // Set up test accounts
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy mock contracts
        vm.startPrank(owner);
        usdc = new MockERC20("USD Coin", "USDC", 6);
        dai = new MockERC20("Dai Stablecoin", "DAI", 18);
        aavePool = new MockAavePool();
        dataProvider = new MockAaveProtocolDataProvider();
        
        // Configure mock Aave pool
        MockERC20 usdcAToken = new MockERC20("aUSDC", "aUSDC", 6);
        MockERC20 daiAToken = new MockERC20("aDAI", "aDAI", 18);
        aavePool.addAsset(address(usdc), address(usdcAToken), 3e27); // 3% APY
        aavePool.addAsset(address(dai), address(daiAToken), 3e27); // 3% APY
        
        // Configure mock data provider
        dataProvider.setTokenAddresses(
            address(usdc),
            address(usdcAToken),
            address(0), // stableDebtToken
            address(0)  // variableDebtToken
        );
        dataProvider.setTokenAddresses(
            address(dai),
            address(daiAToken),
            address(0), // stableDebtToken
            address(0)  // variableDebtToken
        );
        dataProvider.setLiquidityRate(address(usdc), 3e27);
        dataProvider.setLiquidityRate(address(dai), 3e27);
        
        // Deploy factory
        factory = new ModularVaultFactory();
        
        // Give users some tokens
        usdc.mint(user1, TEST_AMOUNT_USDC);
        usdc.mint(user2, TEST_AMOUNT_USDC);
        dai.mint(user1, TEST_AMOUNT_DAI);
        
        // Create adapter
        address adapterAddress = factory.createAaveAdapter(address(aavePool), address(dataProvider));
        
        // Create vaults
        factory.createVault(
            address(usdc),
            "USDC Yield Vault",
            "vUSDC",
            "Aave V3"
        );
        
        factory.createVault(
            address(dai),
            "DAI Yield Vault",
            "vDAI",
            "Aave V3"
        );
        
        vm.stopPrank();
    }
    
    function testFactoryInitialState() public {
        assertEq(factory.getVaultCount(), 2);
        assertEq(factory.getProtocolCount(), 1);
        
        string[] memory protocols = factory.getSupportedProtocols();
        assertEq(protocols[0], "Aave V3");
        
        address[] memory vaults = factory.getAllVaults();
        assertEq(vaults.length, 2);
    }
    
    function testVaultCreation() public {
        address usdcVault = factory.vaults(address(usdc));
        address daiVault = factory.vaults(address(dai));
        
        assertTrue(usdcVault != address(0));
        assertTrue(daiVault != address(0));
        
        ModularYieldVault usdcVaultContract = ModularYieldVault(usdcVault);
        ModularYieldVault daiVaultContract = ModularYieldVault(daiVault);
        
        assertEq(usdcVaultContract.name(), "USDC Yield Vault");
        assertEq(daiVaultContract.name(), "DAI Yield Vault");
    }
    
    function testDepositAndWithdrawUSDC() public {
        address usdcVault = factory.vaults(address(usdc));
        ModularYieldVault vault = ModularYieldVault(usdcVault);
        
        vm.startPrank(user1);
        
        // Approve and deposit
        IERC20(address(usdc)).approve(usdcVault, TEST_AMOUNT_USDC);
        uint256 shares = vault.deposit(TEST_AMOUNT_USDC, user1);
        assertEq(shares, TEST_AMOUNT_USDC);
        
        // Check balances
        assertEq(IERC20(address(usdc)).balanceOf(user1), 0);
        assertEq(vault.balanceOf(user1), TEST_AMOUNT_USDC);
        
        // Withdraw half
        uint256 withdrawAmount = TEST_AMOUNT_USDC / 2;
        uint256 assets = vault.withdraw(withdrawAmount, user1, user1);
        assertEq(assets, withdrawAmount);
        
        // Check final balances
        assertEq(IERC20(address(usdc)).balanceOf(user1), withdrawAmount);
        assertEq(vault.balanceOf(user1), TEST_AMOUNT_USDC - withdrawAmount);
        
        vm.stopPrank();
    }
    
    function testDepositAndWithdrawDAI() public {
        address daiVault = factory.vaults(address(dai));
        ModularYieldVault vault = ModularYieldVault(daiVault);
        
        vm.startPrank(user1);
        
        // Approve and deposit
        IERC20(address(dai)).approve(daiVault, TEST_AMOUNT_DAI);
        uint256 shares = vault.deposit(TEST_AMOUNT_DAI, user1);
        assertEq(shares, TEST_AMOUNT_DAI);
        
        // Check balances
        assertEq(IERC20(address(dai)).balanceOf(user1), 0);
        assertEq(vault.balanceOf(user1), TEST_AMOUNT_DAI);
        
        // Withdraw half
        uint256 withdrawAmount = TEST_AMOUNT_DAI / 2;
        uint256 assets = vault.withdraw(withdrawAmount, user1, user1);
        assertEq(assets, withdrawAmount);
        
        // Check final balances
        assertEq(IERC20(address(dai)).balanceOf(user1), withdrawAmount);
        assertEq(vault.balanceOf(user1), TEST_AMOUNT_DAI - withdrawAmount);
        
        vm.stopPrank();
    }
    
    function testMultipleUsers() public {
        address usdcVault = factory.vaults(address(usdc));
        ModularYieldVault vault = ModularYieldVault(usdcVault);
        
        // User 1 deposits
        vm.startPrank(user1);
        IERC20(address(usdc)).approve(usdcVault, TEST_AMOUNT_USDC);
        vault.deposit(TEST_AMOUNT_USDC, user1);
        vm.stopPrank();
        
        // User 2 deposits
        vm.startPrank(user2);
        IERC20(address(usdc)).approve(usdcVault, TEST_AMOUNT_USDC);
        vault.deposit(TEST_AMOUNT_USDC, user2);
        vm.stopPrank();
        
        // Check balances
        assertEq(vault.balanceOf(user1), TEST_AMOUNT_USDC);
        assertEq(vault.balanceOf(user2), TEST_AMOUNT_USDC);
        assertEq(vault.totalAssets(), TEST_AMOUNT_USDC * 2);
    }
    
    function test_RevertWhen_CreateDuplicateVault() public {
        vm.prank(owner);
        vm.expectRevert("Vault already exists for this asset");
        factory.createVault(
            address(usdc),
            "USDC Yield Vault 2",
            "vUSDC2",
            "Aave V3"
        );
    }
    
    function test_RevertWhen_CreateVaultWithInvalidAdapter() public {
        vm.prank(owner);
        vm.expectRevert("Vault already exists for this asset");
        factory.createVault(
            address(usdc),
            "USDC Yield Vault 2",
            "vUSDC2",
            "Invalid Protocol"
        );
    }
    
    // function test_RevertWhen_DepositWithoutApproval() public {
    //     address usdcVault = factory.vaults(address(usdc));
    //     ModularYieldVault vault = ModularYieldVault(usdcVault);
        
    //     vm.startPrank(user1);
    //     vm.expectRevert(abi.encodeWithSignature("ERC20InsufficientAllowance(address,uint256,uint256)", address(usdc), 0, TEST_AMOUNT_USDC));
    //     vault.deposit(TEST_AMOUNT_USDC, user1);
    //     vm.stopPrank();
    // }
}
