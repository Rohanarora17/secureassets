// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IYieldProtocolAdapter.sol";

/**
 * @title BaseAdapter
 * @dev Base contract for protocol adapters
 */
abstract contract BaseAdapter is IYieldProtocolAdapter, Ownable {
    // Mapping of supported assets
    mapping(address => bool) private _supportedAssets;
    
    // Events
    event AssetSupported(address indexed asset, bool supported);
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Add or remove support for an asset
     * @param asset Address of the asset
     * @param supported Whether the asset is supported
     */
    function setAssetSupport(address asset, bool supported) internal {
        _supportedAssets[asset] = supported;
        emit AssetSupported(asset, supported);
    }
    
    /**
     * @dev Check if an asset is supported
     * @param asset Address of the asset
     * @return True if the asset is supported
     */
    function supportsAsset(address asset) public view virtual override returns (bool) {
        return _supportedAssets[asset];
    }
    
    /**
     * @dev Returns the name of the protocol
     */
    function protocolName() external pure virtual override returns (string memory);
    
    /**
     * @dev Deposits assets into the protocol
     */
    function deposit(address asset, uint256 amount) external virtual override returns (uint256);
    
    /**
     * @dev Withdraws assets from the protocol
     */
    function withdraw(address asset, uint256 amount, address to) external virtual override returns (uint256);
    
    /**
     * @dev Returns the current APY for the asset
     */
    function getAPY(address asset) external view virtual override returns (uint256);
    
    /**
     * @dev Returns the amount of assets currently supplied
     */
    function getSuppliedBalance(address asset) external view virtual override returns (uint256);
    
    /**
     * @dev Returns the address used to track balance
     */
    function getDepositToken(address asset) external view virtual override returns (address);
}
