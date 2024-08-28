// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {ValidationLib} from '../libraries/ValidationLib.sol';
import {Types} from '../libraries/constants/Types.sol';
import {Events} from '../libraries/constants/Events.sol';
import {Errors} from '../libraries/constants/Errors.sol';
import {StorageLib} from '../libraries/StorageLib.sol';
import {IPublicationActionModule} from '../interfaces/IPublicationActionModule.sol';
import {IPublicationCollectModule} from '../interfaces/IPublicationCollectModule.sol';
import {IModuleRegistry} from '../interfaces/IModuleRegistry.sol';
import {INFTCertificate} from '../interfaces/INFTCertificate.sol';
import {IEduxHub} from '../interfaces/IEduxHub.sol';

library PublicationLib {
    function MODULE_REGISTRY() internal view returns (IModuleRegistry) {
        return IModuleRegistry(IEduxHub(address(this)).getModuleRegistry());
    }

    /**
     * @notice Publishes a course to a given profile.
     *
     * @param courseParams The CourseParams struct.
     *
     * @return uint256 The created publication's pubId.
     */
    function course(Types.CourseParams calldata courseParams,address transactionExecutor) external returns (uint256) {
        ValidationLib.validateCourseInitData(courseParams.collectModule , courseParams.certificateModule);
        uint256 pubIdAssigned = ++StorageLib.getProfile(courseParams.profileId).pubCount;

        Types.Publication storage _course = StorageLib.getPublication(courseParams.profileId, pubIdAssigned);
        _course.contentURI = courseParams.contentURI;
        _course.pubType = Types.PublicationType.Course;
        _course.certificateModule = courseParams.certificateModule;
        _course.collectModule = courseParams.collectModule;

        bytes memory collectModulesReturnData = _initPubCollectModule(
            InitCollectModuleParams(
                courseParams.profileId,
                transactionExecutor,
                pubIdAssigned,
                courseParams.collectModule,
                courseParams.collectModulesInitData
            )
        );

        emit Events.CourseCreated(
            courseParams,
            pubIdAssigned,
            collectModulesReturnData,
            transactionExecutor,
            block.timestamp
        );

        return pubIdAssigned;
    }

    /**
     * @notice Publishes a lesson to a given profile.
     *
     * @param lessonParams the LessonParams struct.
     *
     * @return uint256 The created publication's pubId.
     */
    function lesson(
        Types.LessonParams calldata lessonParams,
        address transactionExecutor
    ) external returns (uint256) {
        ValidationLib.validatePointedPubAsCourse(lessonParams.pointedProfileId,lessonParams.pointedPubId);
        ValidationLib.validatePublisherIsOwnerOfCourse(lessonParams.profileId,lessonParams.pointedProfileId);

        uint256 pubIdAssigned = ++StorageLib.getProfile(lessonParams.profileId).pubCount;

        Types.Publication storage _lesson = StorageLib.getPublication(lessonParams.profileId, pubIdAssigned);
        _lesson.contentURI = lessonParams.contentURI;
        _lesson.pubType = Types.PublicationType.Lesson;

        Types.Publication storage _course = StorageLib.getPublication(lessonParams.pointedProfileId, lessonParams.pointedPubId);
        _course.totalLesson = ++_course.totalLesson;
        _fillRootOfPublicationInStorage(_lesson, lessonParams.pointedProfileId, lessonParams.pointedPubId);

        bytes[] memory actionModulesReturnDatas = _initPubActionModules(
            InitActionModuleParams(
                lessonParams.profileId,
                transactionExecutor,
                pubIdAssigned,
                lessonParams.actionModules,
                lessonParams.actionModulesInitDatas
            )
        );

        emit Events.LessonCreated(
            lessonParams,
            pubIdAssigned,
            actionModulesReturnDatas,
            transactionExecutor,
            block.timestamp
        );

        return pubIdAssigned;
    }

    /**
     * @notice Publishes a rating to a given publication.
     *
     * @param ratingParams the RatingParams struct.
     *
     * @return uint256 The created publication's pubId.
     */
    function rating(Types.RatingParams calldata ratingParams, address transactionExecutor) external returns (uint256) {
        ValidationLib.validatePointedPubAsCourse(ratingParams.pointedProfileId, ratingParams.pointedPubId);
        ValidationLib.validateCourseIsCollectedByProfile(ratingParams.profileId, ratingParams.pointedPubId);
        ValidationLib.validateCourseIsRatedByProfile(ratingParams.profileId, ratingParams.pointedPubId);
        Types.Profile storage _profile = StorageLib.getProfile(ratingParams.profileId);
        uint256 pubIdAssigned = ++_profile.pubCount;

        Types.Publication storage _publication = StorageLib.getPublication(ratingParams.profileId, pubIdAssigned);
        _publication.pointedProfileId = ratingParams.pointedProfileId;
        _publication.pointedPubId = ratingParams.pointedPubId;
        _publication.contentURI = ratingParams.contentURI;
        _publication.pubType = Types.PublicationType.Rating;
        _fillRootOfPublicationInStorage(_publication, ratingParams.pointedProfileId, ratingParams.pointedPubId);
        _profile.courseData[ratingParams.pointedPubId].isRated = true;

        emit Events.RatingCreated(
            ratingParams,
            pubIdAssigned,
            transactionExecutor,
            block.timestamp
        );

        return pubIdAssigned;
    }

    /**
     * @notice Publishes a progress to a given publication.
     *
     * @param progressParams the ProgressParams struct.
     *
     * @return uint256 The created publication's pubId.
     */
    function progress(Types.ProgressParams calldata progressParams, address transactionExecutor) external returns (uint256) {
        uint256 pubIdAssigned = _progress(progressParams,transactionExecutor);
        return pubIdAssigned;
    }

    function bulkprogress(Types.ProgressParams[] calldata progressParams, address transactionExecutor) external returns (uint256[] memory) {
        uint256[] memory pubIds = new uint256[](progressParams.length);
        uint256 i;
        while (i < progressParams.length) {
            ValidationLib.validateAddressIsProfileOwner(transactionExecutor, progressParams[i].profileId);
            uint256 pubIdAssigned = _progress(progressParams[i], transactionExecutor);
            pubIds[i] = pubIdAssigned;
            unchecked {
                ++i;
            }
        }
        return pubIds;
    }

    /**
     * @notice completeCourse for completed course with the specified parameters.
     *
     * @param profileId The token ID of the profile.
     *
     * @param pointedProfileId The token ID of the publication's profile.
     *
     * @param pointedPublication The course publication id.
     *
     * @param transactionExecutor The owner of the profile.
     *
     * @return uint256 TokenId for received NFT certificate
     */
    function completeCourse(uint256 profileId, uint256 pointedProfileId, uint256 pointedPublication, address transactionExecutor) external returns (uint256){
        return INFTCertificate(
            _getCertificateNFTAddress(pointedProfileId, pointedPublication)
            ).claimCertificate(profileId, pointedProfileId, pointedPublication, transactionExecutor);
    }

    function _progress(Types.ProgressParams calldata progressParams, address transactionExecutor) internal returns (uint256) {
        ValidationLib.validatePointedPubAsLesson(progressParams.pointedProfileId, progressParams.pointedPubId);
        Types.Publication storage _lesson = StorageLib.getPublication(progressParams.pointedProfileId, progressParams.pointedPubId);
        ValidationLib.validateCourseIsCollectedByProfile(progressParams.profileId, _lesson.rootPubId);
        ValidationLib.validateLessonIsCompletedByProfile(progressParams.profileId, progressParams.pointedPubId);
        Types.Profile storage _profile = StorageLib.getProfile(progressParams.profileId);
        uint256 pubIdAssigned = ++_profile.pubCount;

        Types.Publication storage _publication = StorageLib.getPublication(progressParams.profileId, pubIdAssigned);
        _publication.pointedProfileId = progressParams.pointedProfileId;
        _publication.pointedPubId = progressParams.pointedPubId;
        _publication.contentURI = progressParams.metadataURI;
        _publication.pubType = Types.PublicationType.Progress;
        _fillRootOfPublicationInStorage(_publication, progressParams.pointedProfileId, progressParams.pointedPubId);

        _profile.lessonProgress[progressParams.pointedPubId] = true;
        _profile.courseData[_lesson.rootPubId].progress = ++_profile.courseData[_lesson.rootPubId].progress;

        
        emit Events.ProgressCreated(
            progressParams,
            pubIdAssigned,
            transactionExecutor,
            block.timestamp
        );

        return pubIdAssigned;
    }

    function getPublicationType(uint256 profileId, uint256 pubId) internal view returns (Types.PublicationType) {
        Types.Publication storage _publication = StorageLib.getPublication(profileId, pubId);
        Types.PublicationType pubType = _publication.pubType;
        return pubType;
    }

    function isLessonCompleted(uint256 profileId, uint256 pointedPubId) external view returns (bool) {
        Types.Profile storage _profile = StorageLib.getProfile(profileId);
        return _profile.lessonProgress[pointedPubId];
    }

    function isCourseCompleted(uint256 profileId, uint256 pointedProfile, uint256 pointedPubId) external view returns (bool) {
        Types.Profile storage _profile = StorageLib.getProfile(profileId);
        Types.Publication storage _coursePublication = StorageLib.getPublication(pointedProfile, pointedPubId);
        if(_coursePublication.pubType != Types.PublicationType.Course){
            revert Errors.InvalidPointedPub();
        }

        return _profile.courseData[pointedPubId].progress == _coursePublication.totalLesson;
    }

    function getContentURI(uint256 profileId, uint256 pubId) external view returns (string memory) {
        Types.Publication storage _publication = StorageLib.getPublication(profileId, pubId);
        Types.PublicationType pubType = _publication.pubType;
        if (pubType == Types.PublicationType.Nonexistent) {
            pubType = getPublicationType(profileId, pubId);
        }

        return StorageLib.getPublication(profileId, pubId).contentURI;

    }

    function _getCertificateNFTAddress(uint256 pointedProfileId, uint256 pointedPublication) internal view returns (address) {
        Types.Publication storage _publication = StorageLib.getPublication(pointedProfileId, pointedPublication);
        
        if(_publication.pubType != Types.PublicationType.Course) {
            revert Errors.InvalidPointedPub();
        }
        return _publication.certificateModule;
    }

    function _fillRootOfPublicationInStorage(
        Types.Publication storage _publication,
        uint256 pointedProfileId,
        uint256 pointedPubId
    ) internal returns (uint256) {
        Types.Publication storage _pubPointed = StorageLib.getPublication(pointedProfileId, pointedPubId);
        Types.PublicationType pubPointedType = _pubPointed.pubType;
        if (pubPointedType == Types.PublicationType.Course || pubPointedType == Types.PublicationType.Lesson) {
            // The publication pointed is a course or lesson.
            _publication.rootPubId = pointedPubId;
            return _publication.rootProfileId = pointedProfileId;
        } 
        return 0;
    }


    // Needed to avoid 'stack too deep' issue.
    struct InitActionModuleParams {
        uint256 profileId;
        address transactionExecutor;
        uint256 pubId;
        address[] actionModules;
        bytes[] actionModulesInitDatas;
    }

    function _initPubActionModules(InitActionModuleParams memory params) private returns (bytes[] memory) {
        if (params.actionModules.length != params.actionModulesInitDatas.length) {
            revert Errors.ArrayMismatch();
        }

        bytes[] memory actionModuleInitResults = new bytes[](params.actionModules.length);

        uint256 i;
        while (i < params.actionModules.length) {
            MODULE_REGISTRY().verifyModule(
                params.actionModules[i],
                uint256(IModuleRegistry.ModuleType.PUBLICATION_ACTION_MODULE)
            );

            StorageLib.getPublication(params.profileId, params.pubId).actionModuleEnabled[
                params.actionModules[i]
            ] = true;

            actionModuleInitResults[i] = IPublicationActionModule(params.actionModules[i]).initializePublicationAction(
                params.profileId,
                params.pubId,
                params.transactionExecutor,
                params.actionModulesInitDatas[i]
            );

            unchecked {
                ++i;
            }
        }

        return actionModuleInitResults;
    }

    struct InitCollectModuleParams {
        uint256 profileId;
        address transactionExecutor;
        uint256 pubId;
        address collectModule;
        bytes collectModulesInitData;
    }

    function _initPubCollectModule(InitCollectModuleParams memory params) private returns (bytes memory) {

        bytes memory collectModuleInitResult;

            MODULE_REGISTRY().verifyModule(
                params.collectModule,
                uint256(IModuleRegistry.ModuleType.PUBLICATION_COLLECT_MODULE)
            );

            collectModuleInitResult = IPublicationCollectModule(params.collectModule).initializePublicationCollect(
                params.profileId,
                params.pubId,
                params.transactionExecutor,
                params.collectModulesInitData
            );

        return collectModuleInitResult;
    }
}