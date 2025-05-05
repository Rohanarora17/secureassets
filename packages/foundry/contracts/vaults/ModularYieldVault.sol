// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IYieldProtocolAdapter.sol";

contract ModularYieldVault is ERC4626, Ownable {
    using SafeERC20 for IERC20;

    IYieldProtocolAdapter public immutable protocolAdapter;
    uint256 public minIdleAssets;
    bool public depositsPaused;

    event MinIdleAssetsUpdated(uint256 newMinIdleAssets);
    event DepositsPaused(bool paused);

    constructor(
        address _asset,
        string memory _name,
        string memory _symbol,
        address _protocolAdapter
    ) ERC4626(IERC20(_asset)) ERC20(_name, _symbol) Ownable(msg.sender) {
        require(_protocolAdapter != address(0), "Invalid adapter address");
        protocolAdapter = IYieldProtocolAdapter(_protocolAdapter);
        require(protocolAdapter.supportsAsset(_asset), "Asset not supported by adapter");
        minIdleAssets = 1e16; // 0.01 tokens
    }

    function setMinIdleAssets(uint256 _minIdleAssets) external onlyOwner {
        minIdleAssets = _minIdleAssets;
        emit MinIdleAssetsUpdated(_minIdleAssets);
    }

    function setDepositsPaused(bool _paused) external onlyOwner {
        depositsPaused = _paused;
        emit DepositsPaused(_paused);
    }

    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        require(!depositsPaused, "Deposits are paused");
        super._deposit(caller, receiver, assets, shares);
        
        // Transfer assets to protocol adapter
        IERC20(asset()).approve(address(protocolAdapter), assets);
        protocolAdapter.deposit(asset(), assets);
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual override {
        // Get aToken address
        address aToken = protocolAdapter.getDepositToken(asset());
        require(aToken != address(0), "Invalid aToken address");
        
        // Approve adapter to spend aTokens
        IERC20(aToken).approve(address(protocolAdapter), assets);
        
        // Withdraw assets from protocol adapter
        protocolAdapter.withdraw(asset(), assets, address(this));
        
        super._withdraw(caller, receiver, owner, assets, shares);
    }

    function totalAssets() public view virtual override returns (uint256) {
        return protocolAdapter.getSuppliedBalance(asset());
    }

    function getAPY() external view returns (uint256) {
        return protocolAdapter.getAPY(asset());
    }
} 