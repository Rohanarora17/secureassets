// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../contracts/interfaces/IAaveProtocolDataProvider.sol";

contract MockAaveProtocolDataProvider is IAaveProtocolDataProvider, Ownable {
    mapping(address => address) private aTokens;
    mapping(address => address) private stableDebtTokens;
    mapping(address => address) private variableDebtTokens;
    mapping(address => uint256) private liquidityRates;

    constructor() Ownable(msg.sender) {}

    function setTokenAddresses(
        address asset,
        address aToken,
        address stableDebtToken,
        address variableDebtToken
    ) external {
        aTokens[asset] = aToken;
        stableDebtTokens[asset] = stableDebtToken;
        variableDebtTokens[asset] = variableDebtToken;
    }

    function setLiquidityRate(address asset, uint256 rate) external {
        liquidityRates[asset] = rate;
    }

    function getReserveTokensAddresses(address asset) external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    ) {
        return (
            aTokens[asset],
            stableDebtTokens[asset],
            variableDebtTokens[asset]
        );
    }

    function getReserveData(address asset) external view returns (
        uint256 configuration,
        uint128 liquidityIndex,
        uint128 currentLiquidityRate,
        uint128 variableBorrowIndex,
        uint128 currentVariableBorrowRate,
        uint128 currentStableBorrowRate,
        uint40 lastUpdateTimestamp,
        uint16 id,
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress,
        address interestRateStrategyAddress,
        uint128 baseLTVasCollateral
    ) {
        return (
            0, // configuration
            1e27, // liquidityIndex
            uint128(liquidityRates[asset]), // currentLiquidityRate
            1e27, // variableBorrowIndex
            0, // currentVariableBorrowRate
            0, // currentStableBorrowRate
            uint40(block.timestamp), // lastUpdateTimestamp
            0, // id
            aTokens[asset], // aTokenAddress
            stableDebtTokens[asset], // stableDebtTokenAddress
            variableDebtTokens[asset], // variableDebtTokenAddress
            address(0), // interestRateStrategyAddress
            0  // baseLTVasCollateral
        );
    }
} 