// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../interfaces/IYieldProtocolAdapter.sol";

/**
 * @title ModularYieldVault
 * @dev An ERC-4626 compliant vault that can use different protocol adapters for yield generation
 */
contract ModularYieldVault is ERC4626, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Math for uint256;

    // Active protocol adapter
    IYieldProtocolAdapter public protocolAdapter;
    
    // Minimum idle assets to keep in vault (not supplied to protocol)
    uint256 public minIdleAssets;
    
    // Tracks if deposits are paused
    bool public depositsPaused;
    
    // Events
    event ProtocolAdapterUpdated(address indexed oldAdapter, address indexed newAdapter);
    event DepositsPaused(bool status);
    event MinIdleAssetsUpdated(uint256 oldMinIdle, uint256 newMinIdle);
    event Supplied(address indexed asset, uint256 amount);
    event Withdrawn(address indexed asset, uint256 amount);

    /**
     * @dev Constructor sets up the vault with the asset token and protocol adapter
     * @param _asset The underlying asset token
     * @param _name The name of the vault token
     * @param _symbol The symbol of the vault token
     * @param _protocolAdapter Address of the protocol adapter
     */
    constructor(
        address _asset,
        string memory _name,
        string memory _symbol,
        address _protocolAdapter
    ) ERC4626(IERC20(_asset)) ERC20(_name, _symbol) Ownable(msg.sender) {
        require(_protocolAdapter != address(0), "Invalid protocol adapter");
        
        protocolAdapter = IYieldProtocolAdapter(_protocolAdapter);
        require(protocolAdapter.supportsAsset(_asset), "Asset not supported by protocol");
        
        // Set default minimum idle assets
        minIdleAssets = 1e16; // 0.01 asset units (adjust based on asset decimals)
    }

    /**
     * @dev Pause or unpause deposits
     * @param status True to pause, false to unpause
     */
    function setDepositsPaused(bool status) external onlyOwner {
        depositsPaused = status;
        emit DepositsPaused(status);
    }

    /**
     * @dev Update the protocol adapter
     * @param _protocolAdapter New protocol adapter address
     */
    function setProtocolAdapter(address _protocolAdapter) external onlyOwner {
        require(_protocolAdapter != address(0), "Invalid protocol adapter");
        
        address assetAddress = asset();
        IYieldProtocolAdapter newAdapter = IYieldProtocolAdapter(_protocolAdapter);
        
        // Ensure the new adapter supports our asset
        require(newAdapter.supportsAsset(assetAddress), "Asset not supported by new protocol");
        
        // If we have assets supplied to the current protocol, withdraw them
        address currentDepositToken = protocolAdapter.getDepositToken(assetAddress);
        if (currentDepositToken != address(0)) {
            uint256 suppliedBalance = IERC20(currentDepositToken).balanceOf(address(this));
            if (suppliedBalance > 0) {
                // Withdraw all assets from current protocol
                protocolAdapter.withdraw(assetAddress, type(uint256).max, address(this));
            }
        }
        
        address oldAdapter = address(protocolAdapter);
        protocolAdapter = newAdapter;
        
        // Supply assets to the new protocol
        _rebalance();
        
        emit ProtocolAdapterUpdated(oldAdapter, _protocolAdapter);
    }
    
    /**
     * @dev Set minimum idle assets to keep in vault
     * @param _minIdleAssets New minimum idle assets
     */
    function setMinIdleAssets(uint256 _minIdleAssets) external onlyOwner {
        uint256 oldMinIdle = minIdleAssets;
        minIdleAssets = _minIdleAssets;
        emit MinIdleAssetsUpdated(oldMinIdle, _minIdleAssets);
    }

    /**
     * @dev Returns the total amount of the underlying asset managed by this vault
     * @return The total amount of assets
     */
    function totalAssets() public view override returns (uint256) {
        address assetAddress = asset();
        
        // Total assets are the sum of:
        // 1. Assets currently in this contract
        // 2. Assets supplied to the protocol
        return IERC20(assetAddress).balanceOf(address(this)) + _protocolSuppliedAssets();
    }

    /**
     * @dev Returns the amount of assets supplied to the protocol
     * @return The amount of assets in the protocol
     */
    function _protocolSuppliedAssets() internal view returns (uint256) {
        address depositToken = protocolAdapter.getDepositToken(asset());
        if (depositToken == address(0)) return 0;
        
        return IERC20(depositToken).balanceOf(address(this));
    }

    /**
     * @dev Deposit assets into the vault and receive shares
     * @param assets Amount of assets to deposit
     * @param receiver Address to receive the shares
     * @return shares Amount of shares minted
     */
    function deposit(uint256 assets, address receiver) public override nonReentrant returns (uint256) {
        require(!depositsPaused, "Deposits are paused");
        require(assets > 0, "Cannot deposit 0 assets");
        
        // Transfer assets from sender to this contract
        // The ERC4626 implementation will handle this
        uint256 shares = super.deposit(assets, receiver);
        
        // Supply assets to the protocol, but keep some idle for gas efficiency and liquidity
        _rebalance();
        
        return shares;
    }
    
    /**
     * @dev Mint exact shares by depositing assets
     * @param shares Amount of shares to mint
     * @param receiver Address to receive the shares
     * @return assets Amount of assets deposited
     */
    function mint(uint256 shares, address receiver) public override nonReentrant returns (uint256) {
        require(!depositsPaused, "Deposits are paused");
        require(shares > 0, "Cannot mint 0 shares");
        
        // Calculate assets needed for shares and mint shares
        // The ERC4626 implementation will handle this
        uint256 assets = super.mint(shares, receiver);
        
        // Supply assets to the protocol, but keep some idle for gas efficiency and liquidity
        _rebalance();
        
        return assets;
    }
    
    /**
     * @dev Withdraw assets from the vault by burning shares
     * @param assets Amount of assets to withdraw
     * @param receiver Address to receive the assets
     * @param owner Address that owns the shares
     * @return shares Amount of shares burned
     */
    function withdraw(uint256 assets, address receiver, address owner) public override nonReentrant returns (uint256) {
        require(assets > 0, "Cannot withdraw 0 assets");
        
        // Check if we need to withdraw from the protocol
        uint256 availableAssets = IERC20(asset()).balanceOf(address(this));
        if (availableAssets < assets) {
            // Need to withdraw from the protocol
            _withdrawFromProtocol(assets - availableAssets);
        }
        
        // Withdraw assets and burn shares
        // The ERC4626 implementation will handle this
        return super.withdraw(assets, receiver, owner);
    }
    
    /**
     * @dev Redeem shares for assets
     * @param shares Amount of shares to redeem
     * @param receiver Address to receive the assets
     * @param owner Address that owns the shares
     * @return assets Amount of assets withdrawn
     */
    function redeem(uint256 shares, address receiver, address owner) public override nonReentrant returns (uint256) {
        require(shares > 0, "Cannot redeem 0 shares");
        
        // Calculate assets needed for shares
        uint256 assets = previewRedeem(shares);
        
        // Check if we need to withdraw from the protocol
        uint256 availableAssets = IERC20(asset()).balanceOf(address(this));
        if (availableAssets < assets) {
            // Need to withdraw from the protocol
            _withdrawFromProtocol(assets - availableAssets);
        }
        
        // Redeem shares for assets
        // The ERC4626 implementation will handle this
        return super.redeem(shares, receiver, owner);
    }
    
    /**
     * @dev Rebalance assets between idle and protocol
     */
    function _rebalance() internal {
        address assetAddress = asset();
        uint256 currentBalance = IERC20(assetAddress).balanceOf(address(this));
        
        // Keep minimum idle assets and supply the rest to the protocol
        if (currentBalance > minIdleAssets) {
            uint256 amountToSupply = currentBalance - minIdleAssets;
            _supplyToProtocol(amountToSupply);
        }
    }
    
    /**
     * @dev Supply assets to the protocol to generate yield
     * @param amount Amount of assets to supply
     */
    function _supplyToProtocol(uint256 amount) internal {
        if (amount == 0) return;
        
        address assetAddress = asset();
        
        // Approve protocol adapter to spend the assets
        IERC20(assetAddress).approve(address(protocolAdapter), amount);
        
        // Supply to protocol
        protocolAdapter.deposit(assetAddress, amount);
        
        emit Supplied(assetAddress, amount);
    }
    
    /**
     * @dev Withdraw assets from the protocol
     * @param amount Amount of assets to withdraw
     */
    function _withdrawFromProtocol(uint256 amount) internal {
        if (amount == 0) return;
        
        address assetAddress = asset();
        
        // Withdraw from protocol
        protocolAdapter.withdraw(assetAddress, amount, address(this));
        
        emit Withdrawn(assetAddress, amount);
    }
    
    /**
     * @dev Emergency function to recover stuck tokens
     * @param token Address of the token to recover
     * @param to Address to send the tokens to
     * @param amount Amount of tokens to recover
     */
    function recoverERC20(address token, address to, uint256 amount) external onlyOwner {
        require(token != asset(), "Cannot withdraw the underlying asset");
        IERC20(token).safeTransfer(to, amount);
    }
    
    /**
     * @dev Manual rebalancing function
     */
    function rebalance() external onlyOwner {
        _rebalance();
    }
    
    /**
     * @dev Get the current APY from the protocol for the underlying asset
     * @return The current APY in basis points (1% = 100)
     */
    function currentApy() external view returns (uint256) {
        return protocolAdapter.getAPY(asset());
    }
    
    /**
     * @dev Get the protocol name
     * @return The name of the current protocol
     */
    function getProtocolName() external view returns (string memory) {
        return protocolAdapter.protocolName();
    }
}