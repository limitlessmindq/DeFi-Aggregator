// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibAllowances {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("erc20.allowances");

    event Approval(address indexed owner, address indexed spender, uint256 value);

    struct AllowancesStates {
        mapping(address => mapping(address => uint256)) allowances;
    }

    function diamondStorage() internal pure returns (AllowancesStates storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        } 
    }

    function approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        AllowancesStates storage ds = diamondStorage();
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        ds.allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function spendAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        AllowancesStates storage ds = diamondStorage();
        uint256 currentAllowance = ds.allowances[_owner][_spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _amount, "ERC20: insufficient allowance");
            unchecked {
                approve(_owner, _spender, currentAllowance - _amount);
            }
        }
    }
}
