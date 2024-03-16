// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFeeCollection {
    error Forbidden();
    error InvalidQuoteType(QUOTE_TYPE);

    event WhitelistChange(bytes4 selector, bool action);
    event FeeEnabled(bool enabled);
    event FeeToChange(address feeToSetter);
    event FeeFactorChanged(uint256 oldFeeFactor, uint256 newFeeFactor);
    event DefaultFeeFactorChanged(uint256 oldDefaultExchangeRate, uint256 newDefaultExchangeRate);
    event DefaultQuoteTypeChanged(QUOTE_TYPE currentQuoteType, QUOTE_TYPE newQuoteType);

    enum QUOTE_TYPE {
        ORACLE,
        FIXED_FEE_FACTOR
    }

    function feeToSetter() external view returns(address);
    function feeEnabled() external view returns(bool);
    function feeFactor() external view returns(uint256);
    function defaultFeeFactor() external view returns(uint256);
    function defaultQuoteType() external view returns(QUOTE_TYPE);
    function estimateFee() external view returns(uint256);
    function signWhitelist(bytes4 sign) external view returns(bool);
    
    function whitelistChange(bytes4 sign, bool action) external;
    function setFeeFactor(uint256 _feeFactor) external;
    function setDefaultFeeFactor(uint256 _defaultFeeFactor) external;
    function setDefaultQuoteType(QUOTE_TYPE _quote_type) external; 
    function setFeeEnable(bool enabled) external;
    function setFeeToSetter(address _feeToSetter) external;
}
