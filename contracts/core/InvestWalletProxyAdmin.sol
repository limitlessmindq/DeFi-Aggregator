// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IUpgradeLogic } from "./interfaces/IUpgradeLogic.sol";

import { IInvestWalletFactory } from "./interfaces/IInvestWalletFactory.sol";
import { IInvestWalletProxyAdmin } from "./interfaces/IInvestWalletProxyAdmin.sol";

/// @title VaultProxyAdmin
/// @notice This contract is a common proxy admin for all vaults deployed via factory.
/// @dev Through this contract, all vaults can be updated to a new implementation.
contract InvestWalletProxyAdmin is IInvestWalletProxyAdmin {
    // =========================
    // Storage
    // =========================

    IInvestWalletFactory public immutable investWalletFactory;

    constructor(address _investWalletFactory) {
        investWalletFactory = IInvestWalletFactory(_investWalletFactory);
    }

    // =========================
    // InvestWallet implementation logic
    // =========================

    /// @inheritdoc IInvestWalletProxyAdmin
    function initializeImplementation(
        address investWallet,
        address implementation
    ) external {
        if (msg.sender != address(investWalletFactory)) {
            revert InvestWalletProxyAdmin_CallerIsNotFactory();
        }

        IUpgradeLogic(investWallet).upgrade(implementation);
    }

    /// @inheritdoc IInvestWalletProxyAdmin
    function upgrade(address investWallet, uint256 version) external {
        if (IUpgradeLogic(investWallet).owner() != msg.sender) {
            revert InvestWalletProxyAdmin_SenderIsNotVaultOwner();
        }

        if (version > investWalletFactory.versions() || version == 0) {
            revert InvestWalletProxyAdmin_VersionDoesNotExist();
        }

        address currentImplementation = IUpgradeLogic(investWallet).implementation();
        address implementation = investWalletFactory.implementation(version);

        if (currentImplementation == implementation) {
            revert InvestWalletProxyAdmin_CannotUpdateToCurrentVersion();
        }

        IUpgradeLogic(investWallet).upgrade(implementation);
    }
}
