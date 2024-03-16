// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRegistry {

    error Forbidden();

    event Initialization(address indexed user, address indexed smartAccountAddress, uint256 indexed smartAccountID);

    struct InvestWalletInfo {
        address investWalletAddress;
        uint256 investWalletId;
    }

    function factory() external view returns(address);

    function allInvestWallets(uint256) external view returns(address);
    
    function investWalletAddr(uint256 investWalletId) external view returns(address);

    function mainWalletAddr(address investWallet) external view returns(address);

    function initialize(address mainWallet, address investWallet) external;

    function getInvestWalletInfo(address mainWallet) external view returns(InvestWalletInfo memory);

    function getAllInvestWallets() external view returns(uint256);
}
