// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/adapters/AaveV3Adapter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockAavePool.sol";
import "../mocks/MockAaveProtocolDataProvider.sol";

contract AaveV3AdapterIntegrationTest is Test {
    AaveV3Adapter public adapter;
    MockERC20 public mockAsset;
    MockERC20 public mockAToken;
    MockAavePool public mockAavePool;
    MockAaveProtocolDataProvider public mockDataProvider;
    
    address public user;
    uint256 public constant TEST_AMOUNT = 1000 * 1e6; // 1000 USDC (6 decimals)
    uint256 public constant APY_RAY = 3e27; // 3% APY in ray (10^27)
    
    function setUp() public {
        // Set up test accounts
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
        adapter = new AaveV3Adapter(address(mockAavePool), address(mockDataProvider));
        
        // Give user some tokens
        mockAsset.mint(user, TEST_AMOUNT);
        // Give pool some tokens for withdrawals
        mockAsset.mint(address(mockAavePool), TEST_AMOUNT * 2);
    }
    
    function testProtocolName() public view {
        assertEq(adapter.protocolName(), "Aave V3");
    }
    
    function testSupportsAsset() public view {
        assertTrue(adapter.supportsAsset(address(mockAsset)));
        assertFalse(adapter.supportsAsset(address(0)));
    }
    
    function testGetDepositToken() public view {
        assertEq(adapter.getDepositToken(address(mockAsset)), address(mockAToken));
        assertEq(adapter.getDepositToken(address(0)), address(0));
    }
    
    function testGetAPY() public {
        // First deposit some tokens to ensure the adapter is initialized
        vm.startPrank(user);
        mockAsset.approve(address(adapter), TEST_AMOUNT);
        adapter.deposit(address(mockAsset), TEST_AMOUNT);
        vm.stopPrank();
        
        uint256 apy = adapter.getAPY(address(mockAsset));
        assertEq(apy, 300); // 3% APY = 300 basis points
    }
    
    function testDepositAndWithdraw() public {
        vm.startPrank(user);
        
        // Approve adapter to spend tokens
        mockAsset.approve(address(adapter), TEST_AMOUNT);
        
        // Deposit tokens
        uint256 deposited = adapter.deposit(address(mockAsset), TEST_AMOUNT);
        assertEq(deposited, TEST_AMOUNT);
        
        // Check balance
        uint256 balance = adapter.getSuppliedBalance(address(mockAsset));
        assertEq(balance, TEST_AMOUNT);
        
        // Approve adapter to spend aTokens
        mockAToken.approve(address(adapter), TEST_AMOUNT);
        
        // Withdraw half
        uint256 withdrawAmount = TEST_AMOUNT / 2;
        uint256 withdrawn = adapter.withdraw(address(mockAsset), withdrawAmount, user);
        assertEq(withdrawn, withdrawAmount);
        
        // Check new balance
        balance = adapter.getSuppliedBalance(address(mockAsset));
        assertEq(balance, TEST_AMOUNT - withdrawAmount);
        
        vm.stopPrank();
    }
    
    function testUpdateAavePool() public {
        address newPool = address(0x123);
        adapter.updateAavePool(newPool);
        assertEq(adapter.aavePool(), newPool);
    }
    
    function testUpdateDataProvider() public {
        address newProvider = address(0x456);
        adapter.updateDataProvider(newProvider);
        assertEq(adapter.dataProvider(), newProvider);
    }
    
    function testUpdateReferralCode() public {
        uint16 newCode = 123;
        adapter.updateReferralCode(newCode);
        assertEq(adapter.referralCode(), newCode);
    }
    
    function test_RevertWhen_DepositUnsupportedAsset() public {
        vm.startPrank(user);
        vm.expectRevert("Asset not supported by Aave");
        adapter.deposit(address(0x123), TEST_AMOUNT);
        vm.stopPrank();
    }
    
    function test_RevertWhen_WithdrawUnsupportedAsset() public {
        vm.startPrank(user);
        vm.expectRevert("Asset not supported by Aave");
        adapter.withdraw(address(0x123), TEST_AMOUNT, user);
        vm.stopPrank();
    }
}
