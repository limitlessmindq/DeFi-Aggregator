// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface IGateway {
    function name() external view returns(string memory);
}

error FunctionNotFound(bytes4 _functionSelector);
error InsufficientFundsToPayTheFee(uint256 estimateFee);
error AccessDenied();

struct DiamondArgs {
    address owner;
    address init;
    bytes initCalldata;
}

contract Entry {

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
        bytes memory returnData;
        string memory eventNames;
        bytes memory eventParams;
        string memory gatewayName;        

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), 0x5FbDB2315678afecb367f032d93F642f64180aa3, ptr, calldatasize(), 0, 0)

            // get any return value
            returnData := ptr
            returndatacopy(add(returnData, 32), 0, returndatasize())
            mstore(returnData, returndatasize())

            if iszero(result) {
                revert(add(returnData, 32), returndatasize())
            }

            mstore(0x40, add(add(returnData, 0x20), returndatasize()))
        }
        
        (eventNames, eventParams) = decodeEvent(returnData);
        gatewayName = IGateway(0x5FbDB2315678afecb367f032d93F642f64180aa3).name();

        console.logBytes(returnData);
        console.logString(eventNames);
        console.logBytes(eventParams);
        console.logString(gatewayName);

        emit LogCast(
            msg.sender, // main wallet
            address(this), // invest wallet
            msg.value, // value
            1, // protocol fee
            gatewayName, // gateway name
            0x5FbDB2315678afecb367f032d93F642f64180aa3, // gateway address
            eventNames, // event name
            eventParams // event params
        );
    }

    receive() external payable {}
}

// 0x0000000000000000000000005fbdb2315678afecb367f032d93f642f64180aa3000000000000000000000000000000000000000000000000000000000001869f
// 0x4c6f674465706f73697428616464726573732c75696e7432353629
