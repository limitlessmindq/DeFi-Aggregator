// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITreasure {
    error InsufficientFunds();

    event FundsRecived(address sender, uint256 amount);
    event TokensWithdrawal(address token, address to, uint256 amount);
    event NativeTokensWithdrawal(address to, uint256 amount);

    function withdrawTokens(address token, address to, uint256 amount) external;
    function withdrawNativeTokens(address to, uint256 amount) external;
}
