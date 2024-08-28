// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {ValidationLib} from '../libraries/ValidationLib.sol';
import {Types} from '../libraries/constants/Types.sol';
import {Errors} from '../libraries/constants/Errors.sol';
import {Events} from '../libraries/constants/Events.sol';
import {StorageLib} from '../libraries/StorageLib.sol';
import {IModuleRegistry} from '../interfaces/IModuleRegistry.sol';
import {IEduxHub} from '../interfaces/IEduxHub.sol';

library ProfileLib {
    function MODULE_REGISTRY() internal view returns (IModuleRegistry) {
        return IModuleRegistry(IEduxHub(address(this)).getModuleRegistry());
    }

    function ownerOf(uint256 profileId) internal view returns (address) {
        address profileOwner = StorageLib.getTokenData(profileId).owner;
        if (profileOwner == address(0)) {
            revert Errors.TokenDoesNotExist();
        }
        return profileOwner;
    }

    function exists(uint256 profileId) internal view returns (bool) {
        return StorageLib.getTokenData(profileId).owner != address(0);
    }

    /**
     * @notice Creates a profile with the given parameters to the given address. Minting happens
     * in the hub.
     *
     * @param createProfileParams The CreateProfileParams struct containing the following parameters:
     *      to: The address receiving the profile.
     * @param profileId The profile ID to associate with this profile NFT (token ID).
     */
    function createProfile(Types.CreateProfileParams calldata createProfileParams, uint256 profileId) external {
        emit Events.ProfileCreated(profileId, msg.sender, createProfileParams.to, block.timestamp);
    }

    function setProfileMetadataURI(
        uint256 profileId,
        string calldata metadataURI,
        address transactionExecutor
    ) external {
        StorageLib.getProfile(profileId).metadataURI = metadataURI;
        emit Events.ProfileMetadataSet(profileId, metadataURI, transactionExecutor, block.timestamp);
    }
}