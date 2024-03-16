// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IInvestWalletFactory } from "./IInvestWalletFactory.sol";

/// @title IVaultProxyAdmin - VaultProxyAdmin interface.
/// @notice This contract is a common proxy admin for all vaults deployed via factory.
/// @dev Through this contract, all vaults can be updated to a new implementation.
interface IInvestWalletProxyAdmin {
    // =========================
    // Storage
    // =========================

    function investWalletFactory() external view returns (IInvestWalletFactory);

    // =========================
    // Errors
    // =========================

    /// @notice Thrown when an anyone other than the address of the factory tries calling the method.
    error InvestWalletProxyAdmin_CallerIsNotFactory();

    /// @notice Thrown when a non-owner of the vault tries to update its implementation.
    error InvestWalletProxyAdmin_SenderIsNotVaultOwner();

    /// @notice Thrown when an `owner` attempts to update a vault using
    /// a version of the implementation that doesn't exist.
    error InvestWalletProxyAdmin_VersionDoesNotExist();

    /// @notice Thrown when there's an attempt to update the vault to its
    /// current implementation address.
    error InvestWalletProxyAdmin_CannotUpdateToCurrentVersion();

    // =========================
    // InvestWallet implementation logic
    // =========================

    /// @notice Sets the `vault` implementation to an address from the factory.
    /// @param investWallet Address of the vault to be upgraded.
    /// @param implementation The new implementation from the factory.
    /// @dev Can only be called from the vault factory.
    function initializeImplementation(
        address investWallet,
        address implementation
    ) external;

    /// @notice Updates the `investWallet` implementation to an address from the factory.
    /// @param investWallet Address of the investWallet to be upgraded.
    /// @param version The version number of the new implementation from the `_implementations` array.
    ///
    /// @dev This function can only be called by the owner of the investWallet.
    /// @dev The version specified should be an existing version in the factory
    /// and must not be the current implementation of the investWallet.
    /// @dev If the function caller is not the owner of the investWallet, it reverts with
    /// `InvestWalletProxyAdmin_SenderIsNotVaultOwner`.
    /// @dev If the specified `version` number is outside the valid range of the implementations
    /// or is zero, it reverts with `InvestWalletProxyAdmin_VersionDoesNotExist`.
    /// @dev If the specified version  is the current implementation, it reverts
    /// with `InvestWalletProxyAdmin_CannotUpdateToCurrentVersion`.
    function upgrade(address investWallet, uint256 version) external;
}
