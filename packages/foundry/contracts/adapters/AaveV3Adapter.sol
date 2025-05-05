// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IYieldProtocolAdapter.sol";
import "../interfaces/IAaveProtocolDataProvider.sol";
import "./BaseAdapter.sol";

// Aave V3 Pool interface defined outside the contract for cleaner code
interface IAavePool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
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
    );
}

/**
 * @title AaveV3Adapter
 * @dev Adapter for Aave V3 protocol
 */
contract AaveV3Adapter is BaseAdapter {
    using SafeERC20 for IERC20;

    // Aave V3 Pool address
    address public aavePool;
    
    // Aave Protocol Data Provider
    address public dataProvider;
    
    // Referral code for Aave (usually 0)
    uint16 public referralCode = 0;
    
    // Cache of asset to aToken mapping
    mapping(address => address) private aTokens;
    
    // Events
    event Deposited(address indexed asset, uint256 amount);
    event Withdrawn(address indexed asset, uint256 amount, address indexed to);

    /**
     * @dev Constructor sets up the adapter with Aave addresses
     * @param _aavePool Address of the Aave V3 Pool contract
     * @param _dataProvider Address of the Aave Protocol Data Provider
     */
    constructor(address _aavePool, address _dataProvider) {
        require(_aavePool != address(0), "Invalid Aave pool address");
        require(_dataProvider != address(0), "Invalid data provider address");
        
        aavePool = _aavePool;
        dataProvider = _dataProvider;
    }
    
    /**
     * @dev Returns the name of the protocol
     */
    function protocolName() external pure override returns (string memory) {
        return "Aave V3";
    }
    
    /**
     * @dev Deposits assets into Aave
     * @param asset Address of the asset to deposit
     * @param amount Amount of assets to deposit
     * @return Amount of assets actually deposited
     */
    function deposit(address asset, uint256 amount) external override returns (uint256) {
        require(supportsAsset(asset), "Asset not supported by Aave");
        require(amount > 0, "Amount must be greater than 0");
        
        // Transfer assets from sender to this contract
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        
        // Approve Aave to spend the assets
        IERC20(asset).approve(aavePool, amount);
        
        // Supply to Aave on behalf of msg.sender
        IAavePool(aavePool).supply(asset, amount, msg.sender, referralCode);
        
        emit Deposited(asset, amount);
        
        return amount;
    }
    
    /**
     * @dev Withdraws assets from Aave
     * @param asset Address of the asset to withdraw
     * @param amount Amount of assets to withdraw
     * @param to Address to receive the withdrawn assets
     * @return Amount of assets actually withdrawn
     */
    function withdraw(address asset, uint256 amount, address to) external override returns (uint256) {
        require(supportsAsset(asset), "Asset not supported by Aave");
        require(amount > 0, "Amount must be greater than 0");
        
        // Get aToken address
        address aToken = getDepositToken(asset);
        require(aToken != address(0), "Invalid aToken address");
        
        // Transfer aTokens from msg.sender to this contract
        IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount);
        
        // Approve Aave to spend aTokens
        IERC20(aToken).approve(aavePool, amount);
        
        // Withdraw from Aave
        uint256 withdrawn = IAavePool(aavePool).withdraw(asset, amount, to);
        
        emit Withdrawn(asset, withdrawn, to);
        
        return withdrawn;
    }
    
    /**
     * @dev Returns the current APY for the asset in Aave
     * @param asset Address of the asset
     * @return Current APY in basis points (1% = 100)
     */
    function getAPY(address asset) external view override returns (uint256) {
        require(supportsAsset(asset), "Asset not supported by Aave");
        
        // Get liquidity rate from Aave Protocol Data Provider
        (,, uint128 liquidityRate,,,,,,,,,,) = IAaveProtocolDataProvider(dataProvider).getReserveData(asset);
        
        // Convert from ray (10^27) to basis points (1% = 100)
        // Aave returns the rate in ray units (10^27)
        // We want to convert it to basis points (1% = 100)
        // So we multiply by 100 and divide by 10^27
        // For example, 3e27 (3 ray) = 3% APY = 300 basis points
        return (liquidityRate * 100) / 1e27;
    }
    
    /**
     * @dev Returns the amount of assets currently supplied to Aave
     * @param asset Address of the asset
     * @return Amount of assets supplied
     */
    function getSuppliedBalance(address asset) external view override returns (uint256) {
        address aToken = getDepositToken(asset);
        if (aToken == address(0)) return 0;
        
        return IERC20(aToken).balanceOf(msg.sender);
    }
    
    /**
     * @dev Checks if Aave supports a specific asset
     * @param asset Address of the asset
     * @return True if the asset is supported
     */
    function supportsAsset(address asset) public view override returns (bool) {
        if (asset == address(0)) return false;
        
        try IAaveProtocolDataProvider(dataProvider).getReserveTokensAddresses(asset) returns (
            address aTokenAddress,
            address,
            address
        ) {
            return aTokenAddress != address(0);
        } catch {
            return false;
        }
    }
    
    /**
     * @dev Returns the aToken address for an asset
     * @param asset Address of the asset
     * @return Address of the aToken
     */
    function getDepositToken(address asset) public view override returns (address) {
        if (aTokens[asset] != address(0)) {
            return aTokens[asset];
        }
        
        try IAaveProtocolDataProvider(dataProvider).getReserveTokensAddresses(asset) returns (
            address aTokenAddress,
            address,
            address
        ) {
            return aTokenAddress;
        } catch {
            return address(0);
        }
    }
    
    /**
     * @dev Update the Aave pool address
     * @param _aavePool New Aave pool address
     */
    function updateAavePool(address _aavePool) external onlyOwner {
        require(_aavePool != address(0), "Invalid Aave pool address");
        aavePool = _aavePool;
    }
    
    /**
     * @dev Update the data provider address
     * @param _dataProvider New data provider address
     */
    function updateDataProvider(address _dataProvider) external onlyOwner {
        require(_dataProvider != address(0), "Invalid data provider address");
        dataProvider = _dataProvider;
    }
    
    /**
     * @dev Update the referral code
     * @param _referralCode New referral code
     */
    function updateReferralCode(uint16 _referralCode) external onlyOwner {
        referralCode = _referralCode;
    }
    
    /**
     * @dev Emergency function to recover stuck tokens
     * @param token Address of the token to recover
     * @param to Address to send the tokens to
     * @param amount Amount of tokens to recover
     */
    function recoverERC20(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }
}