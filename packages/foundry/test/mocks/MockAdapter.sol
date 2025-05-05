// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../contracts/interfaces/IYieldProtocolAdapter.sol";

contract MockAdapter is IYieldProtocolAdapter {
    using SafeERC20 for IERC20;
    
    mapping(address => address) public depositTokens;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => uint256) public apyRates;
    mapping(address => bool) public supportedAssets;
    
    string public mockProtocolName = "Mock Protocol";
    
    function setProtocolName(string memory name) external {
        mockProtocolName = name;
    }
    
    function protocolName() external view override returns (string memory) {
        return mockProtocolName;
    }
    
    function addAsset(address asset, address depositToken, uint256 apy) external {
        depositTokens[asset] = depositToken;
        apyRates[asset] = apy;
        supportedAssets[asset] = true;
    }
    
    function deposit(address asset, uint256 amount) external override returns (uint256) {
        require(supportedAssets[asset], "Asset not supported");
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        balances[asset][msg.sender] += amount;
        return amount;
    }
    
    function withdraw(address asset, uint256 amount, address to) external override returns (uint256) {
        require(supportedAssets[asset], "Asset not supported");
        require(balances[asset][msg.sender] >= amount, "Insufficient balance");
        
        balances[asset][msg.sender] -= amount;
        IERC20(asset).safeTransfer(to, amount);
        
        return amount;
    }
    
    function getAPY(address asset) external view override returns (uint256) {
        return apyRates[asset];
    }
    
    function getSuppliedBalance(address asset) external view override returns (uint256) {
        return balances[asset][msg.sender];
    }
    
    function supportsAsset(address asset) external view override returns (bool) {
        return supportedAssets[asset];
    }
    
    function getDepositToken(address asset) external view override returns (address) {
        return depositTokens[asset];
    }
}
