// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.15;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract WEDU is ERC20 {
    constructor() ERC20("Wrapped EDU", "WEDU") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}