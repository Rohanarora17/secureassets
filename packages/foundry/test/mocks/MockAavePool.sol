// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MockERC20.sol";

contract MockAavePool is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => address) public aTokens;
    mapping(address => uint256) public liquidityRates; // In ray units (10^27)
    
    event Supplied(address indexed asset, uint256 amount, address indexed onBehalfOf);
    event Withdrawn(address indexed asset, uint256 amount, address indexed to);

    constructor() Ownable(msg.sender) {}
    
    // Add an asset to the mock pool
    function addAsset(address asset, address aToken, uint256 liquidityRate) external {
        aTokens[asset] = aToken;
        liquidityRates[asset] = liquidityRate;
    }
    
    // Mock Aave supply function
    function supply(address asset, uint256 amount, address onBehalfOf, uint16) external {
        require(aTokens[asset] != address(0), "Asset not supported");
        
        // Transfer asset tokens from sender to this contract
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        
        // Mint aTokens to onBehalfOf
        MockERC20(aTokens[asset]).mint(onBehalfOf, amount);
        
        emit Supplied(asset, amount, onBehalfOf);
    }
    
    // Mock Aave withdraw function
    function withdraw(address asset, uint256 amount, address to) external returns (uint256) {
        require(aTokens[asset] != address(0), "Asset not supported");
        
        // Check aToken balance
        uint256 aTokenBalance = IERC20(aTokens[asset]).balanceOf(msg.sender);
        require(aTokenBalance >= amount, "Insufficient aToken balance");
        
        // Burn aTokens from sender
        MockERC20(aTokens[asset]).burn(msg.sender, amount);
        
        // Transfer underlying tokens to recipient
        IERC20(asset).safeTransfer(to, amount);
        
        emit Withdrawn(asset, amount, to);
        
        return amount;
    }
    
    // Mock getReserveData function
    function getReserveData(address asset) external view returns (
        uint256 unbacked,
        uint256 accruedToTreasuryScaled,
        uint256 totalAToken,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 stableBorrowRate,
        uint256 lastUpdateTimestamp,
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress,
        address interestRateStrategyAddress,
        uint8 id,
        uint128 borrowCap,
        uint128 supplyCap,
        uint16 reserveFactor
    ) {
        return (
            0, // unbacked
            0, // accruedToTreasuryScaled
            0, // totalAToken
            0, // totalStableDebt
            0, // totalVariableDebt
            liquidityRates[asset], // liquidityRate
            0, // variableBorrowRate
            0, // stableBorrowRate
            block.timestamp, // lastUpdateTimestamp
            aTokens[asset], // aTokenAddress
            address(0), // stableDebtTokenAddress
            address(0), // variableDebtTokenAddress
            address(0), // interestRateStrategyAddress
            0, // id
            0, // borrowCap
            0, // supplyCap
            0  // reserveFactor
        );
    }
}
