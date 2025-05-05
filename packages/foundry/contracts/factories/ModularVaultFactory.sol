// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../adapters/AaveV3Adapter.sol";
import "../interfaces/IYieldProtocolAdapter.sol";
import "../vaults/ModularYieldVault.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ModularVaultFactory
 * @dev Factory contract for deploying ModularYieldVault instances with protocol adapters
 */
contract ModularVaultFactory is Ownable {
    // Mapping from asset address to vault address
    mapping(address => address) public vaults;
    
    // Array of all vaults created
    address[] public allVaults;
    
    // Protocol adapters registry
    mapping(string => address) public protocolAdapters;
    string[] public supportedProtocols;
    
    // Events
    event VaultCreated(address indexed asset, address indexed vault, string protocol);
    event AdapterRegistered(string protocol, address indexed adapter);
    event AdapterUpdated(string protocol, address indexed oldAdapter, address indexed newAdapter);
    
    /**
     * @dev Constructor sets the owner
     */
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Register a new protocol adapter
     * @param protocolName Name of the protocol
     * @param adapter Address of the protocol adapter
     */
    function registerAdapter(string memory protocolName, address adapter) external onlyOwner {
        require(bytes(protocolName).length > 0, "Protocol name cannot be empty");
        require(adapter != address(0), "Invalid adapter address");
        
        if (protocolAdapters[protocolName] == address(0)) {
            // New adapter
            protocolAdapters[protocolName] = adapter;
            supportedProtocols.push(protocolName);
            emit AdapterRegistered(protocolName, adapter);
        } else {
            // Update existing adapter
            address oldAdapter = protocolAdapters[protocolName];
            protocolAdapters[protocolName] = adapter;
            emit AdapterUpdated(protocolName, oldAdapter, adapter);
        }
    }
    
    /**
     * @dev Create a new ModularYieldVault for an asset using a specific protocol
     * @param asset Address of the underlying asset
     * @param name Name of the vault token
     * @param symbol Symbol of the vault token
     * @param protocolName Name of the protocol to use
     * @return vault Address of the created vault
     */
    function createVault(
        address asset,
        string memory name,
        string memory symbol,
        string memory protocolName
    ) external onlyOwner returns (address vault) {
        require(asset != address(0), "Invalid asset address");
        require(vaults[asset] == address(0), "Vault already exists for this asset");
        
        address adapter = protocolAdapters[protocolName];
        require(adapter != address(0), "Protocol adapter not registered");
        
        // Check if the adapter supports the asset
        require(IYieldProtocolAdapter(adapter).supportsAsset(asset), "Asset not supported by protocol");
        
        // Create new vault
        ModularYieldVault newVault = new ModularYieldVault(
            asset,
            name,
            symbol,
            adapter
        );
        
        // Transfer ownership to the factory owner
        newVault.transferOwnership(owner());
        
        // Store vault address
        vault = address(newVault);
        vaults[asset] = vault;
        allVaults.push(vault);
        
        emit VaultCreated(asset, vault, protocolName);
    }
    
    /**
     * @dev Create and register an Aave V3 adapter
     * @param aavePool Address of the Aave V3 Pool
     * @param dataProvider Address of the Aave Protocol Data Provider
     * @return adapter Address of the created adapter
     */
    function createAaveAdapter(address aavePool, address dataProvider) external onlyOwner returns (address adapter) {
        require(aavePool != address(0), "Invalid Aave pool address");
        require(dataProvider != address(0), "Invalid data provider address");
        
        // Create new Aave adapter
        AaveV3Adapter newAdapter = new AaveV3Adapter(aavePool, dataProvider);
        
        // Transfer ownership to the factory owner
        newAdapter.transferOwnership(owner());
        
        // Register the adapter
        adapter = address(newAdapter);
        protocolAdapters["Aave V3"] = adapter;
        supportedProtocols.push("Aave V3");
        emit AdapterRegistered("Aave V3", adapter);
        
        return adapter;
    }
    
    /**
     * @dev Get all vaults created by this factory
     * @return Array of vault addresses
     */
    function getAllVaults() external view returns (address[] memory) {
        return allVaults;
    }
    
    /**
     * @dev Get the number of vaults created
     * @return Number of vaults
     */
    function getVaultCount() external view returns (uint256) {
        return allVaults.length;
    }
    
    /**
     * @dev Get all supported protocols
     * @return Array of protocol names
     */
    function getSupportedProtocols() external view returns (string[] memory) {
        return supportedProtocols;
    }
    
    /**
     * @dev Get the number of supported protocols
     * @return Number of protocols
     */
    function getProtocolCount() external view returns (uint256) {
        return supportedProtocols.length;
    }
}