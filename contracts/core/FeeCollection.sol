// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IFeeCollection } from "./interfaces/IFeeCollection.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FeeCollection is IFeeCollection {
    
    AggregatorV3Interface internal priceFeed;

    address public feeToSetter;
    bool public feeEnabled;

    uint256 public feeFactor;
    uint256 public defaultFeeFactor;
    QUOTE_TYPE public defaultQuoteType = QUOTE_TYPE.ORACLE;

    mapping(bytes4 => bool) public signWhitelist;

    constructor(address _feeToSetter, uint256 _feeFactor, uint256 _defaultFeeFactor) {
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        feeToSetter = _feeToSetter;
        feeFactor = _feeFactor;
        defaultFeeFactor = _defaultFeeFactor;
    }

    modifier onlyFeeToSetter() {
        if(msg.sender != feeToSetter) {
            revert Forbidden();
        }
        _;
    }

    function estimateFee() external view returns (uint256 fee) {
        if (defaultQuoteType == QUOTE_TYPE.ORACLE) {
            fee = feeFactor / getThePrice() * 10**18;
        } else {
            fee = defaultFeeFactor;
        }  
    }

    function getThePrice() internal view returns (uint) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price) / 10**8;
    }

    function whitelistChange(bytes4 sign, bool action) external onlyFeeToSetter {
        signWhitelist[sign] = action;
        emit WhitelistChange(sign, action);
    } 

    function setFeeFactor(uint256 _feeFactor) external onlyFeeToSetter {
        feeFactor = _feeFactor;
        emit FeeFactorChanged(feeFactor, _feeFactor);
    }

    function setDefaultFeeFactor(uint256 _defaultFeeFactor) external onlyFeeToSetter {
        defaultFeeFactor = _defaultFeeFactor;
        emit DefaultFeeFactorChanged(defaultFeeFactor, _defaultFeeFactor);
    }

    function setDefaultQuoteType(QUOTE_TYPE _quoteType) external onlyFeeToSetter {
        if (_quoteType > QUOTE_TYPE.FIXED_FEE_FACTOR) {
            revert InvalidQuoteType(_quoteType);
        }
            
        defaultQuoteType = _quoteType;
        emit DefaultQuoteTypeChanged(defaultQuoteType, _quoteType);
    }

    function setFeeEnable(bool enabled) external onlyFeeToSetter {
        feeEnabled = enabled;
        emit FeeEnabled(feeEnabled);
    }

    function setFeeToSetter(address _feeToSetter) external onlyFeeToSetter {
        feeToSetter = _feeToSetter;
        emit FeeToChange(feeToSetter);
    }
}
