// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

library ModuleErrors {
    // Reward Action Module
    error PublicationIdNotProvided();
    error RewardAmountCannotBeZero();
    error ProfileIsAlreadyRewarded();
    error LessonIsNotCompletedByProfile();
    error TransferNotAllowed();

    // CollectRestricted
    error NotCollectModule();

    //Base Fee Collect Module

    error ModuleDataMismatch();
    error NotHub();
    error InitParamsInvalid();
    error InvalidParams();
    error MintLimitExceeded();
    error CollectExpired();
    error NotActionModule();
    error CollectNotAllowed();
    error AlreadyInitialized();

    // Base NFT Certificate

    error CourseIsNotCompletedByProfile();
    error TokenTransferIsBlock();
    error CertificateIsAlreadyClaimedByProfile();
}