// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { IERC20 } from "./interfaces/IERC20.sol";
import { IRegistry } from "./interfaces/IRegistry.sol";

contract Registry is IRegistry {
    
    address public immutable factory;
    address[] public allInvestWallets;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    // main wallet => investment wallet info
    mapping(address => InvestWalletInfo) private investWallet;

    // investment wallet id =>  invest wallet
    mapping(uint256 => address) public investWalletAddr;
    
    // investment wallet => main wallet 
    mapping(address => address) public mainWalletAddr; 

    function initialize(address mainWallet, address _investWallet) external {
        if(msg.sender != factory) {
            revert Forbidden();
        }
        
        allInvestWallets.push(_investWallet);
        uint256 investmentWalletId = allInvestWallets.length;
        
        investWallet[mainWallet] = InvestWalletInfo(_investWallet, investmentWalletId);
        investWalletAddr[investmentWalletId] = mainWallet;
        mainWalletAddr[_investWallet] = mainWallet;

        emit Initialization(mainWallet, _investWallet, investmentWalletId);
    }

    function getInvestWalletInfo(address mainWallet) external view returns(InvestWalletInfo memory) {
        return investWallet[mainWallet];
    }

    function getAllInvestWallets() external view returns(uint256) {
        return allInvestWallets.length;
    }
}
