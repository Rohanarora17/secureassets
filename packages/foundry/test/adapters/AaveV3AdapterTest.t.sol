// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/adapters/AaveV3Adapter.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockAavePool.sol";
import "../mocks/MockAaveProvider.sol";
import "../mocks/MockAaveProtocolDataProvider.sol";

contract AaveV3AdapterTest is Test {
    AaveV3Adapter public adapter;
    MockERC20 public mockAsset;
    MockERC20 public mockAToken;
    MockAavePool public mockAavePool;
    MockAaveProvider public mockDataProvider;
    MockAaveProtocolDataProvider public mockProtocolDataProvider;
    
    address public owner = address(1);
    address public user = address(2);
    uint256 public constant INITIAL_BALANCE = 1000 ether;
    uint256 public constant DEPOSIT_AMOUNT = 100 ether;
    uint256 public constant APY_RAY = 3e27; // 3% APY in ray (10^27)
    address public constant USDC = address(0x123);
    
    function setUp() public {
        // Deploy mock contracts
        mockAsset = new MockERC20("Mock Asset", "ASSET", 18);
        mockAToken = new MockERC20("Mock aToken", "aASSET", 18);
        mockAavePool = new MockAavePool();
        mockDataProvider = new MockAaveProvider();
        mockProtocolDataProvider = new MockAaveProtocolDataProvider();
        
        // Configure mock Aave
        mockAavePool.addAsset(address(mockAsset), address(mockAToken), APY_RAY);
        mockProtocolDataProvider.setTokenAddresses(
            address(mockAsset),
            address(mockAToken),
            address(0), // stableDebtToken
            address(0)  // variableDebtToken
        );
        mockProtocolDataProvider.setLiquidityRate(address(mockAsset), APY_RAY);
        
        // Deploy adapter
        vm.prank(owner);
        adapter = new AaveV3Adapter(address(mockAavePool), address(mockProtocolDataProvider));
        
        // Setup initial balances
        mockAsset.mint(user, INITIAL_BALANCE);
        // Give pool some tokens for withdrawals
        mockAsset.mint(address(mockAavePool), INITIAL_BALANCE * 2);
    }
    
    function testProtocolName() public {
        assertEq(adapter.protocolName(), "Aave V3");
    }
    
    function testSupportsAsset() public {
        assertTrue(adapter.supportsAsset(address(mockAsset)));
        assertFalse(adapter.supportsAsset(address(0x123)));
    }
    
    function testGetDepositToken() public {
        assertEq(adapter.getDepositToken(address(mockAsset)), address(mockAToken));
        assertEq(adapter.getDepositToken(address(0x123)), address(0));
    }
    
    function testGetAPY() public {
        uint256 apy = adapter.getAPY(address(mockAsset));
        assertEq(apy, 300); // 3% APY = 300 basis points
    }
    
    function testDeposit() public {
        // Approve the adapter to spend tokens
        vm.startPrank(user);
        mockAsset.approve(address(adapter), DEPOSIT_AMOUNT);
        
        // Deposit tokens
        uint256 depositedAmount = adapter.deposit(address(mockAsset), DEPOSIT_AMOUNT);
        
        // Verify results
        assertEq(depositedAmount, DEPOSIT_AMOUNT);
        assertEq(mockAToken.balanceOf(user), DEPOSIT_AMOUNT);
        assertEq(mockAsset.balanceOf(user), INITIAL_BALANCE - DEPOSIT_AMOUNT);
        vm.stopPrank();
    }
    
    function testDepositInvalidAsset() public {
        vm.startPrank(user);
        vm.expectRevert("Asset not supported by Aave");
        adapter.deposit(address(0x123), DEPOSIT_AMOUNT);
        vm.stopPrank();
    }
    
    function testDepositZeroAmount() public {
        vm.startPrank(user);
        vm.expectRevert("Amount must be greater than 0");
        adapter.deposit(address(mockAsset), 0);
        vm.stopPrank();
    }
    
    function testWithdraw() public {
        // First deposit some tokens
        vm.startPrank(user);
        mockAsset.approve(address(adapter), DEPOSIT_AMOUNT);
        adapter.deposit(address(mockAsset), DEPOSIT_AMOUNT);
        
        // Mint aTokens to the adapter
        mockAToken.mint(address(adapter), DEPOSIT_AMOUNT);
        
        // Approve the adapter to spend aTokens
        mockAToken.approve(address(adapter), DEPOSIT_AMOUNT);
        
        // Now withdraw them
        uint256 withdrawnAmount = adapter.withdraw(address(mockAsset), DEPOSIT_AMOUNT, user);
        
        // Verify results
        assertEq(withdrawnAmount, DEPOSIT_AMOUNT);
        assertEq(mockAsset.balanceOf(user), INITIAL_BALANCE);
        assertEq(mockAToken.balanceOf(user), 0);
        vm.stopPrank();
    }
    
    // Add remaining tests from the original test file...
}
