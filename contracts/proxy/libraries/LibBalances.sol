// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibBalances {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("erc20.balances");

    event Transfer(address indexed from, address indexed to, uint256 value);

    struct BalancesStates {
        mapping(address => uint256) balances;
        uint256 totalSupply;
    }

    function diamondStorage() internal pure returns (BalancesStates storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        } 
    }

    function transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        BalancesStates storage ds = diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = ds.balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            ds.balances[from] = fromBalance - amount;
            ds.balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function mint(address account, uint256 amount) internal {
        BalancesStates storage ds = diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");
        ds.totalSupply += amount;
        unchecked {
            ds.balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) internal {
        BalancesStates storage ds = diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = ds.balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            ds.balances[account] = accountBalance - amount;
            ds.totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
    }
}
