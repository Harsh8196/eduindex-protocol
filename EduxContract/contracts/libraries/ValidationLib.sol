// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Types} from '../libraries/constants/Types.sol';
import {Errors} from '../libraries/constants/Errors.sol';
import {StorageLib} from '../libraries/StorageLib.sol';
import {ProfileLib} from '../libraries/ProfileLib.sol';
import {PublicationLib} from '../libraries/PublicationLib.sol';

/**
 * @title ValidationLib
 * @author EDUIndex Protocol
 */
library ValidationLib {
    function validatePointedPub(uint256 profileId, uint256 pubId) internal view {
        // If it is pointing to itself it will fail because it will return a non-existent type.
        Types.PublicationType pointedPubType = PublicationLib.getPublicationType(profileId, pubId);
        if (pointedPubType == Types.PublicationType.Nonexistent || pointedPubType == Types.PublicationType.Rating || pointedPubType == Types.PublicationType.Progress) {
            revert Errors.InvalidPointedPub();
        }
    }

    function validateAddressIsProfileOwner(address expectedProfileOwner, uint256 profileId) internal view {
        if (expectedProfileOwner != ProfileLib.ownerOf(profileId)) {
            revert Errors.NotProfileOwner();
        }
    }

    function validateProfileCreatorWhitelisted(address profileCreator) internal view {
        if (!StorageLib.profileCreatorWhitelisted()[profileCreator]) {
            revert Errors.NotWhitelisted();
        }
    }

    function validateProfileExists(uint256 profileId) internal view {
        if (!ProfileLib.exists(profileId)) {
            revert Errors.TokenDoesNotExist();
        }
    }

    function validateCourseInitData(address collectModule, address certificateModule) internal pure {
        if (collectModule == address(0)) {
            revert Errors.CollectModuleIsNotProvided();
        }

        if(certificateModule == address(0)) {
            revert Errors.CertificateModuleIsNotProvided();
        }
    }

    function validateCallerIsGovernance() internal view {
        if (msg.sender != StorageLib.getGovernance()) {
            revert Errors.NotGovernance();
        }
    }

    function validatePointedPubAsCourse(
        uint256 targetedProfileId,
        uint256 targetedPubId
    ) internal view {
        Types.PublicationType pointedPubType = PublicationLib.getPublicationType(targetedProfileId, targetedPubId);
        //Check if pointedPubId is course or not
        if (pointedPubType != Types.PublicationType.Course) {
            revert Errors.InvalidPointedPub();
        }
    }

    function validatePublisherIsOwnerOfCourse(
        uint256 profileId,
        uint256 targetedProfileId
    ) internal pure {
        //check if lesson publisher is the owner of the pointedPublication(course)
        if (targetedProfileId != profileId) {
            revert Errors.NotProfileOwner();
        }
    }

    function validateProtocolFeeIsCorrect(uint256 receivedFee) internal view {
        Types.TreasuryData storage _treasury = StorageLib.getTreasuryData();
        uint256 treasuryFee = _treasury.treasuryFee[address(0)];

        if (receivedFee < treasuryFee) {
            revert Errors.ProtocolFeeIsNotCorrect();
        }
    }

    function validatePointedPubAsLesson(
        uint256 targetedProfileId,
        uint256 targetedPubId
    ) internal view {
        Types.PublicationType pointedPubType = PublicationLib.getPublicationType(targetedProfileId, targetedPubId);
        //Check if pointedPubId is lesson or not
        if (pointedPubType != Types.PublicationType.Lesson) {
            revert Errors.InvalidPointedPub();
        }
    }

    function validateCourseIsRatedByProfile(
        uint256 profileId,
        uint256 targetedPubId
    ) internal view {
        Types.Profile storage _profile = StorageLib.getProfile(profileId);
        //Check if course is already rated by profile or not
        if (_profile.courseData[targetedPubId].isRated) {
            revert Errors.CourseIsAlreayRatedByProfile();
        }
    }

    function validateLessonIsCompletedByProfile(
        uint256 profileId,
        uint256 targetedPubId
    ) internal view {
        Types.Profile storage _profile = StorageLib.getProfile(profileId);
        //Check if lesson is already completed by profile or not
        if (_profile.lessonProgress[targetedPubId]) {
            revert Errors.LessonIsAlreadyCompletedByProfile();
        }
    }

    function validateCourseIsCollectedByProfile(
        uint256 profileId,
        uint256 targetedPubId
    ) internal view {
        Types.Profile storage _profile = StorageLib.getProfile(profileId);
        //Check if the course is collected by profile or not
        if (!_profile.courseData[targetedPubId].isCollected) {
            revert Errors.CourseIsNotCollectedByProfile();
        }
    }

}