// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Types} from '../libraries/constants/Types.sol';
import {StorageLib} from '../libraries/StorageLib.sol';
import {ValidationLib} from '../libraries/ValidationLib.sol';
import {IPublicationCollectModule} from '../interfaces/IPublicationCollectModule.sol';
import {Errors} from '../libraries/constants/Errors.sol';
import {Events} from '../libraries/constants/Events.sol';

library CollectLib {
    function collect(
        Types.PublicationCollectParams calldata publicationCollectParams,
        address transactionExecutor,
        address collectorProfileOwner
    ) external returns (bytes memory) {

        Types.Profile storage _profile = StorageLib.getProfile(publicationCollectParams.collectorProfileId);

        bytes memory collectModuleReturnData = IPublicationCollectModule(publicationCollectParams.collectModuleAddress)
            .processPublicationCollect(
                Types.ProcessCollectParams({
                    publicationCollectedProfileId: publicationCollectParams.publicationCollectedProfileId,
                    publicationCollectedId: publicationCollectParams.publicationCollectedId,
                    collectorProfileId: publicationCollectParams.collectorProfileId,
                    collectorProfileOwner: collectorProfileOwner,
                    transactionExecutor: transactionExecutor,
                    collectModuleData: publicationCollectParams.collectModuleData
                })
            );
        
        // Update the profile for course collection
        _profile.courseData[publicationCollectParams.publicationCollectedId].isCollected = true;

        emit Events.Collected(publicationCollectParams, collectModuleReturnData, transactionExecutor, block.timestamp);

        return collectModuleReturnData;
    }

}