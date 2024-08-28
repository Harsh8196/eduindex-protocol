// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {BaseFeeCollectModule} from '../collect/base/BaseFeeCollectModule.sol';
import {IPublicationCollectModule} from '../../interfaces/IPublicationCollectModule.sol';
import {EduxModuleMetadata} from '../EduxModuleMetadata.sol';
import {EduxModule} from '../EduxModule.sol';
import {ModuleTypes} from '../libraries/constants/ModuleTypes.sol';
import {Types} from '../../libraries/constants/Types.sol';
import {HubRestricted} from '../../base/HubRestricted.sol';

/**
 * @title SimpleFeeCollectModule
 * @author Edux Protocol
 *
 * @notice This is a simple Edux CollectModule implementation, allowing customization of time to collect and
 * number of collects.
 *
 * You can build your own collect modules by inheriting from BaseFeeCollectModule and adding your
 * functionality along with getPublicationData function.
 */
contract SimpleFeeCollectModule is BaseFeeCollectModule, EduxModuleMetadata, HubRestricted, IPublicationCollectModule {
    constructor(
        address hub,
        address moduleRegistry,
        address moduleOwner
    ) BaseFeeCollectModule(hub, moduleRegistry) EduxModuleMetadata(moduleOwner) HubRestricted(hub) {}

    /**
     * @inheritdoc IPublicationCollectModule
     * @notice This collect module levies a fee on collects. Thus, we need to decode data.
     * @param data The arbitrary data parameter, decoded into BaseFeeCollectModuleInitData struct:
     *        amount: The collecting cost associated with this publication. 0 for free collect.
     *        collectLimit: The maximum number of collects for this publication. 0 for no limit.
     *        currency: The currency associated with this publication.
     *        endTimestamp: The end timestamp after which collecting is impossible. 0 for no expiry.
     *        recipient: Recipient of collect fees.
     *
     * @return An abi encoded bytes parameter, which is the same as the passed data parameter.
     */
    function initializePublicationCollect(
        uint256 profileId,
        uint256 pubId,
        address /* transactionExecutor */,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        ModuleTypes.BaseFeeCollectCourseInitData memory baseInitData = abi.decode(data, (ModuleTypes.BaseFeeCollectCourseInitData));
        _validateBaseInitData(baseInitData);
        _storeBasePublicationCollectParameters(profileId, pubId, baseInitData);
        return '';
    }

    function processPublicationCollect(
        Types.ProcessCollectParams calldata params
    ) external override onlyHub returns (bytes memory) {
        
        return _processCollect(params);
    }

    /**
     * @notice Returns the publication data for a given publication, or an empty struct if that publication was not
     * initialized with this module.
     *
     * @param profileId The token ID of the profile mapped to the publication to query.
     * @param pubId The publication ID of the publication to query.
     *
     * @return The BaseFeeCollectCourse struct mapped to that publication.
     */
    function getPublicationData(
        uint256 profileId,
        uint256 pubId
    ) external view virtual returns (ModuleTypes.BaseFeeCollectCourse memory) {
        return getBasePublicationData(profileId, pubId);
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public pure override(BaseFeeCollectModule, EduxModule) returns (bool) {
       return BaseFeeCollectModule.supportsInterface(interfaceID) || EduxModule.supportsInterface(interfaceID);
    }
}