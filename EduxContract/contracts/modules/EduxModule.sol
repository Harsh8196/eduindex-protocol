// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IEduxModule} from './interfaces/IEduxModule.sol';

abstract contract EduxModule is IEduxModule {
    /// @inheritdoc IEduxModule
    function supportsInterface(bytes4 interfaceID) public pure virtual override returns (bool) {
        return interfaceID == bytes4(keccak256(abi.encodePacked('Edux_MODULE')));
    }
}