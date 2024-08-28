// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Types} from '../libraries/constants/Types.sol';

/**
 * @title EduxHubStorage
 * @author Edux Protocol
 *
 * @notice This is an abstract contract that ONLY contains storage for the EduxHub contract. This MUST be inherited last
 * to preserve the EduxHub storage layout. Adding storage variables should be done ONLY at the bottom of this contract.
 */
abstract contract EduxHubStorage {

    Types.ProtocolState internal _state; // Slot 10

    mapping(address profileCreator => bool isWhitelisted) internal _profileCreatorWhitelisted; // Slot 11

    mapping(uint256 profileId => Types.ProfileMemory profile) internal _profiles; // Slot 12

    mapping(uint256 profileId => mapping(uint256 pubId => Types.Publication publication)) internal _publications; // Slot 13


    uint256 internal _profileCounter; // Slot 14 - different from totalSupply, as this is not decreased when burning profiles

    address internal _governance; // Slot 15

    address internal _emergencyAdmin; // Slot 16

    address internal _profileTokenURIContract; // Slot 17

}