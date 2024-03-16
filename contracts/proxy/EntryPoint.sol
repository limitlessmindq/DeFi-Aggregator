// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "./libraries/LibDiamond.sol";
import { IFeeCollection } from "../core/interfaces/IFeeCollection.sol";
import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { IGateway } from "./interfaces/IGateway.sol";
import { Registry } from "../core/Registry.sol";

error FunctionNotFound(bytes4 _functionSelector);
error InsufficientFundsToPayTheFee(uint256 estimateFee);
error AccessDenied();

struct DiamondArgs {
    address owner;
    address init;
    bytes initCalldata;
}

contract EntryPoint {

    address public immutable feeCollection;   
    address public immutable registry;

    constructor(IDiamondCut.FacetCut[] memory _diamondCut, DiamondArgs memory _args, address _feeCollection, address _registry) payable {
        LibDiamond.setContractOwner(_args.owner);
        LibDiamond.diamondCut(_diamondCut, _args.init, _args.initCalldata);
        feeCollection = _feeCollection;
        registry = _registry;

        // Code can be added here to perform actions and set state variables.
    }

    function decodeEvent(bytes memory response) internal pure returns (string memory _eventCode, bytes memory _eventParams) {
        if (response.length > 0) {
            (_eventCode, _eventParams) = abi.decode(response, (string, bytes));
        }
    }

    event LogCast(
        address indexed origin,
        address indexed sender,
        uint256 value,
        uint256 protocolFee,
        string targetsNames,
        address targets,
        string eventNames,
        bytes eventParams
    );

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        address mainWallet = Registry(registry).mainWalletAddr(address(this));
        
        if(msg.sender != mainWallet) {
            revert AccessDenied();
        }

        bool whitelist = IFeeCollection(feeCollection).signWhitelist(msg.sig);
        uint256 estimateFee;

        if(!whitelist) {
            estimateFee = IFeeCollection(feeCollection).estimateFee();
            
            if(msg.value < estimateFee) {
                revert InsufficientFundsToPayTheFee(estimateFee);
            }
        }

        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds
            .facetAddressAndSelectorPosition[msg.sig]
            .facetAddress;
        if (facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }

        bytes memory returnData;
        string memory eventNames;
        bytes memory eventParams;
        string memory gatewayName;

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(mload(0x40), 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, mload(0x40), calldatasize(), 0, 0)

            // get any return value
            returnData := add(mload(0x40), calldatasize())
            returndatacopy(add(returnData, 32), 0, returndatasize())
            mstore(returnData, returndatasize())

            if iszero(result) {
                revert(add(returnData, 32), returndatasize())
            }

            mstore(0x40, add(add(returnData, 0x20), returndatasize()))
        }
        
        (eventNames, eventParams) = decodeEvent(returnData);
        gatewayName = IGateway(facet).name();

        emit LogCast(
            msg.sender, // main wallet
            address(this), // invest wallet
            msg.value, // value
            estimateFee, // protocol fee
            gatewayName, // gateway name
            facet, // gateway address
            eventNames, // event name
            eventParams // event params
        );
    }

    receive() external payable {}
}
