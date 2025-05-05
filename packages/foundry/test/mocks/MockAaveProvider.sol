// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAaveProvider {
    mapping(address => address) public aTokens;
    
    constructor() {}
    
    // Add an asset to the mock provider
    function addAsset(address asset, address aToken) external {
        aTokens[asset] = aToken;
    }
    
    // Mock getReserveTokensAddresses function
    function getReserveTokensAddresses(address asset) external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    ) {
        return (
            aTokens[asset],
            address(0),
            address(0)
        );
    }
}
