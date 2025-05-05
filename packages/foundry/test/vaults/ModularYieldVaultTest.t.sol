// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/vaults/ModularYieldVault.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockAdapter.sol";

contract ModularYieldVaultTest is Test {
    ModularYieldVault public vault;
    MockERC20 public underlying;
    MockERC20 public depositToken;
    MockAdapter public adapter;
    
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    uint256 public constant INITIAL_SUPPLY = 100000 ether;
    uint256 public constant DEPOSIT_AMOUNT = 10000 ether;
    uint256 public constant APY = 500; // 5% APY in basis points
    
    function setUp() public {
        // Deploy mock tokens
        underlying = new MockERC20("Test Token", "TEST", 18);
        depositToken = new MockERC20("aTest Token", "aTEST", 18);
        
        // Deploy mock adapter
        adapter = new MockAdapter();
        adapter.addAsset(address(underlying), address(depositToken), APY);
        
        // Deploy vault
        vm.prank(owner);
        vault = new ModularYieldVault(address(underlying), "Test Vault", "vTEST", address(adapter));
        
        // Setup initial balances
        underlying.mint(user1, INITIAL_SUPPLY);
        underlying.mint(user2, INITIAL_SUPPLY);
    }
    
    function testInitialState() public {
        assertEq(vault.name(), "Test Vault");
        assertEq(vault.symbol(), "vTEST");
        assertEq(vault.asset(), address(underlying));
        assertEq(address(vault.protocolAdapter()), address(adapter));
        assertEq(vault.totalAssets(), 0);
        assertEq(vault.minIdleAssets(), 1e16);
        assertFalse(vault.depositsPaused());
    }
    
    // Add remaining tests from the original test file...
}
