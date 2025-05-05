// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/factories/ModularVaultFactory.sol";
import "../../contracts/adapters/AaveV3Adapter.sol";
import "../../contracts/vaults/ModularYieldVault.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockAdapter.sol";

contract ModularVaultFactoryTest is Test {
    ModularVaultFactory public factory;
    address public owner = address(1);
    
    // Mock protocol
    MockERC20 public asset1;
    MockERC20 public asset2;
    address public mockAavePool = address(0x100);
    address public mockDataProvider = address(0x200);
    
    function setUp() public {
        // Deploy mock assets
        asset1 = new MockERC20("Asset 1", "AST1", 18);
        asset2 = new MockERC20("Asset 2", "AST2", 18);
        
        // Deploy factory
        vm.prank(owner);
        factory = new ModularVaultFactory();
    }
    
    // Add tests from the original test file...
}
