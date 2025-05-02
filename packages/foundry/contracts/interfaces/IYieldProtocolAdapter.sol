// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldProtocolAdapter
 * @dev Interface for DeFi protocol adapters
 */
interface IYieldProtocolAdapter {
    /**
     * @dev Returns the name of the protocol
     */
    function protocolName() external view returns (string memory);
    
    /**
     * @dev Deposits assets into the protocol
     * @param asset Address of the asset to deposit
     * @param amount Amount of assets to deposit
     * @return Amount of assets actually deposited
     */
    function deposit(address asset, uint256 amount) external returns (uint256);
    
    /**
     * @dev Withdraws assets from the protocol
     * @param asset Address of the asset to withdraw
     * @param amount Amount of assets to withdraw
     * @param to Address to receive the withdrawn assets
     * @return Amount of assets actually withdrawn
     */
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    
    /**
     * @dev Returns the current APY for the asset in the protocol
     * @param asset Address of the asset
     * @return Current APY in basis points (1% = 100)
     */
    function getAPY(address asset) external view returns (uint256);
    
    /**
     * @dev Returns the amount of assets currently supplied to the protocol
     * @param asset Address of the asset
     * @return Amount of assets supplied
     */
    function getSuppliedBalance(address asset) external view returns (uint256);
    
    /**
     * @dev Checks if the protocol supports a specific asset
     * @param asset Address of the asset
     * @return True if the asset is supported
     */
    function supportsAsset(address asset) external view returns (bool);
    
    /**
     * @dev Returns the address used to track balance in the protocol (e.g., aToken in Aave)
     * @param asset Address of the asset
     * @return Address of the token representing the deposit
     */
    function getDepositToken(address asset) external view returns (address);
}