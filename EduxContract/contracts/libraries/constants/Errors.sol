// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

library Errors {
    error CannotInitImplementation();
    error Initialized();
    error InvalidOwner();
    error NotOwnerOrApproved();
    error NotHub();
    error TokenDoesNotExist();
    error NotGovernance();
    error NotGovernanceOrEmergencyAdmin();
    error EmergencyAdminCanOnlyPauseFurther();
    error NotProfileOwner();
    error CourseIsAlreayRatedByProfile();
    error LessonIsAlreadyCompletedByProfile();
    error PublicationDoesNotExist();
    error ArrayMismatch();
    error NotWhitelisted();
    error NotRegistered();
    error InvalidParameter();
    error ExecutorInvalid();
    error InvalidPointedPub();
    error NonERC721ReceiverImplementer();
    error AlreadyEnabled();
    error CourseIsNotCollectedByProfile();

    // Module Errors
    error InitParamsInvalid();
    error ActionNotAllowed();
    error ModuleDataMismatch();
    error InvalidParams();
    error MintLimitExceeded();
    error CollectExpired();
    error NotActionModule();
    error CollectNotAllowed();
    error AlreadyInitialized();
    error CertificateModuleIsNotProvided();
    error CollectModuleIsNotProvided();
    error ProtocolFeeIsNotCorrect();
    error CourseIsNotCompletedByProfile();


    // MultiState Errors
    error Paused();
    error PublishingPaused();
    error NotAllowed();
}