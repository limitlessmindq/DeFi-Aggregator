// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IVaultFactory - VaultFactory Interface
/// @notice This contract is a vault factory that implements methods for creating new vaults
/// and updating them via the UpgradeLogic contract.
interface IInvestWalletFactory {
    // =========================
    // Storage
    // =========================

    function registry() external view returns (address);
    
    /// @notice The address of the immutable contract to which the `investWallet` call will be
    /// delegated if the call is made from `ProxyAdmin's` address.
    function upgradeLogic() external view returns (address);

    /// @notice The address from which the call to `investWallet` will delegate it to the `updateLogic`.
    function investWalletProxyAdmin() external view returns (address);

    // =========================
    // Events
    // =========================

    /// @notice Emits when the new `investWallet` has been created.
    /// @param creator The creator of the created investWallet
    /// @param investWallet The address of the created investWallet
    /// @param investWalletId The unique identifier for the investWallet (for `creator` address)
    event InvestWalletCreated(
        address indexed creator,
        address indexed investWallet,
        uint256 investWalletId
    );

    // =========================
    // Errors
    // =========================

    /// @notice Thrown if an attempt is made to initialize the contract a second time.
    error InvestWalletFactory_AlreadyInitialized();

    /// @notice Thrown when a `creator` attempts to create a vault using
    /// a version of the implementation that doesn't exist.
    error InvestWalletFactory_VersionDoesNotExist();

    /// @notice Thrown when a `creator` tries to create a vault with an `vaultId`
    /// that's already in use.
    /// @param creator The address which tries to create the vault.
    /// @param investWalletId The id that is already used.
    error InvestWalletFactory_IdAlreadyUsed(address creator, uint256 investWalletId);

    /// @notice Thrown when a `creator` attempts to create a vault with an vaultId == `0`
    /// or when the `creator` address is the same as the `proxyAdmin`.
    error InvestWalletFactory_InvalidDeployArguments();

    error InvestWalletFactory_YouAlreadyHaveAnInvestWallet();

    // =========================
    // Vault implementation logic
    // =========================

    /// @notice Adds a `newImplemetation` address to the list of implementations.
    /// @param newImplemetation The address of the new implementation to be added.
    ///
    /// @dev Only callable by the owner of the contract.
    /// @dev After adding, the new implementation will be at the last index
    /// (i.e., version is `_implementations.length`).
    function addNewImplementation(address newImplemetation) external;

    /// @notice Retrieves the implementation address for a given `version`.
    /// @param version The version number of the desired implementation.
    /// @return impl_ The address of the specified implementation version.
    ///
    /// @dev If the `version` number is greater than the length of the `_implementations` array
    /// or the array is empty, `InvestWalletFactory_VersionDoesNotExist` error is thrown.
    function implementation(uint256 version) external view returns (address);

    /// @notice Returns the total number of available implementation versions.
    /// @return The total count of versions in the `_implementations` array.
    function versions() external view returns (uint256);

    // =========================
    // Main functions
    // =========================

    /// @notice Computes the address of a `investWallet` deployed using `deploy` method.
    /// @param creator The address of the creator of the investWallet.
    /// @param investWalletId The id of the investWallet.
    /// @dev `creator` and `id` are part of the salt for the `create2` opcode.
    function predictDeterministicInvestWalletAddress(
        address creator,
        uint256 investWalletId
    ) external view returns (address predicted);

    /// @notice Deploys a new `investWallet` based on a specified `version`.
    /// @param creator Address that will be set as the initial owner of the new investWallet.
    /// @param version The version number of the investWallet implementation to which
    ///        the new investWallet will delegate.
    ///        Used in combination with `creator` for `create2` salt.
    /// @return The address of the newly deployed `investWallet`.
    ///
    /// @dev If the given `version` number is greater than the length of  the `_implementations`
    /// array or if the array is empty, it reverts with `InvestWalletFactory_VersionDoesNotExist`.
    function deploy(
        address creator,
        uint256 version
    ) external returns (address);
}
