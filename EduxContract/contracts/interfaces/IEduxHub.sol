// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import {IEduxProtocol} from './IEduxProtocol.sol';
import {IEduxGovernable} from './IEduxGovernable.sol';

interface IEduxHub is
    IEduxProtocol,
    IEduxGovernable
{}