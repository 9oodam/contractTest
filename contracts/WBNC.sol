// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BounswapERC20.sol";

contract WBNC is Token(_name, _symbol, _amount, _uri) {
    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);
    }

    receive() external payable virtual {
        deposit();
    }
}