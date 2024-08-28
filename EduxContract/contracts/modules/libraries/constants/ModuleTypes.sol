// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @title ModuleTypes
 * @author Edux Protocol
 *
 * @notice A standard library of data ModuleTypes used throughout the Edux Protocol modules.
 */
library ModuleTypes {
    struct ProcessCollectParams {
        uint256 publicationCollectedProfileId;
        uint256 publicationCollectedId;
        uint256 collectorProfileId;
        address collectorProfileOwner;
        address transactionExecutor;
        bytes data;
    }

    struct ProcessActionParams {
        uint256 publicationActedProfileId;
        uint256 publicationActedId;
        uint256 actorProfileId;
        address actorProfileOwner;
        address transactionExecutor;
        bytes actionModuleData;
    }

    struct RewardModuleInitParams {
        uint256 publicationProfileId;
        uint256 publicationId;
        uint256 rewardAmount;
    }

    /**
    * @notice A struct containing the necessary data to initialize this Base Fee Collect for Course.
    *
    * @param amount The collecting cost associated with this course. 0 for free collect.
    * @param collectLimit The maximum number of collects for this course. 0 for no limit.
    * @param currency The currency associated with this course fee.
    * @param endTimestamp The end timestamp after which collecting is impossible. 0 for no expiry.
    * @param recipient Recipient of collect fees.
    * @param currentCollects The current number of collects for this course.
    */
    struct BaseFeeCollectCourse {
        uint160 amount;
        uint96 collectLimit;
        address currency;
        uint72 endTimestamp;
        address recipient;
        uint96 currentCollects;
    }

    struct BaseFeeCollectCourseInitData {
        uint160 amount;
        uint96 collectLimit;
        address currency;
        uint72 endTimestamp;
        address recipient;
    }
}