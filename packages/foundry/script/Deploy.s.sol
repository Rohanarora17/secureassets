// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/factories/ModularVaultFactory.sol";
import "../contracts/adapters/AaveV3Adapter.sol";
import "../test/mocks/MockERC20.sol";
import "../test/mocks/MockAavePool.sol";
import "../test/mocks/MockAaveProtocolDataProvider.sol";

/**
 * @notice Main deployment script for all contracts
 * @dev Run this when you want to deploy multiple contracts at once
 *
 * Example: yarn deploy # runs this script(without`--file` flag)
 */
contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy mock contracts for local testing
        MockERC20 mockAsset = new MockERC20("Mock USDC", "mUSDC", 6);
        MockERC20 mockAToken = new MockERC20("Mock aUSDC", "maUSDC", 6);
        MockAavePool mockAavePool = new MockAavePool();
        MockAaveProtocolDataProvider mockDataProvider = new MockAaveProtocolDataProvider();

        // Configure mock Aave
        mockAavePool.addAsset(address(mockAsset), address(mockAToken), 3e27); // 3% APY
        mockDataProvider.setTokenAddresses(
            address(mockAsset),
            address(mockAToken),
            address(0), // stableDebtToken
            address(0)  // variableDebtToken
        );

        // Deploy factory
        ModularVaultFactory factory = new ModularVaultFactory();

        // Create and register Aave adapter
        AaveV3Adapter adapter = new AaveV3Adapter(
            address(mockAavePool),
            address(mockDataProvider)
        );
        factory.registerAdapter("Aave V3", address(adapter));

        // Create vault
        factory.createVault(
            address(mockAsset),
            "USDC Yield Vault",
            "vUSDC",
            "Aave V3"
        );

        vm.stopBroadcast();

        // Log deployed addresses
        console.log("Mock Asset:", address(mockAsset));
        console.log("Mock aToken:", address(mockAToken));
        console.log("Mock Aave Pool:", address(mockAavePool));
        console.log("Mock Data Provider:", address(mockDataProvider));
        console.log("Factory:", address(factory));
        console.log("Adapter:", address(adapter));
        console.log("Vault:", factory.vaults(address(mockAsset)));
    }
}
