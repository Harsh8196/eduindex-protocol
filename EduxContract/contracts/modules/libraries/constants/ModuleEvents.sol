// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

library ModuleEvents {
    // Reward Action Module

    event PublicationRewardRegistered(
        uint256 publicationProfileId,
        uint256 publicationId,
        uint256 rewardAmount
        
    );

    event RewardDistributed(
        address indexed transactionExecutor,
        uint256 indexed publicationId,
        uint256 rewardAmount
    );

    event CertificateIssuedToProfile(
        address indexed transactionExecutor,
        uint256 indexed profileId,
        uint256 indexed tokenId,
        uint256 pointedPublication,
        address certificateNFTContract,
        uint256 timestamp
    );

    event CourseCompletedByProfile(
        address indexed transactionExecutor,
        uint256 indexed profileId,
        uint256 indexed pointedPublication,
        uint256 pointedProfileId,
        uint256 timestamp
    );
}