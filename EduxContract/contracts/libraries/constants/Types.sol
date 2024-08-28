// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @title Types
 * @author EDUIndex Protocol
 *
 * @notice A standard library of data types used throughout the EDUIndex Protocol.
 */
library Types {
    /**
     * @notice ERC721Timestamped storage. Contains the owner address and the mint timestamp for every NFT.
     *
     *
     * @param owner The token owner.
     * @param mintTimestamp The mint timestamp.
     */
    struct TokenData {
        address owner;
        uint96 mintTimestamp;
    }

    /**
    * @notice A struct containing the necessary data for Course.
    *
    * @param isCollected The course is collected by profile.
    * @param isRated The course is rated by profile. Use to prevent double rating.
    * @param progress The progress of the course.
    */
    struct CollectedCourseData {
        bool isCollected;
        bool isRated;
        uint256 progress;
    }

    /**
     * @notice An enum containing the different states the protocol can be in, limiting certain actions.
     *
     * @param Unpaused The fully unpaused state.
     * @param PublishingPaused The state where only publication creation functions are paused.
     * @param Paused The fully paused state.
     */
    enum ProtocolState {
        Unpaused,
        PublishingPaused,
        Paused
    }

    /**
     * @notice An enum specifically used in a helper function to easily retrieve the publication type for integrations.
     *
     * @param Nonexistent An indicator showing the queried publication does not exist.
     * @param Course A standard course, having an URI, action modules and no pointer to another publication.
     * @param Lesson A lesson, having an URI, action modules and a pointer to another publication.
     * @param Rating A rating, having an URI, action modules and a pointer to another publication.
     * @param Progress A progress, having an URI, action modules, and a pointer to another publication.
     */
    enum PublicationType {
        Nonexistent,
        Course,
        Lesson,
        Rating,
        Progress
    }

    /**
     * @notice A struct containing profile data.
     *
     * @param pubCount The number of publications made to this profile.
     * @param metadataURI MetadataURI is used to store the profile's metadata, for example: displayed name, description,
     * interests, etc.
     * @param courseData is used to store the progress of the course
     * @param lessonProgress is used to store the progress of lesson
     */
    struct Profile {
        uint256 pubCount;
        string metadataURI;
        mapping(uint256 => CollectedCourseData) courseData;
        mapping(uint256 => bool) lessonProgress;
    }

    struct ProfileMemory {
        uint256 pubCount; 
        string metadataURI;
    }

    /**
     * @notice A struct containing publication data.
     *
     * @param pointedProfileId The profile token ID to point the publication to.
     * @param pointedPubId The publication ID to point the publication to.
     * These are used to implement the "reference" feature of the platform and is used in:
     * - Lesson
     * - Rating
     * - Progress
     * There are (0,0) if the publication is not pointing to any other publication (i.e. the publication is a Course).
     * @param totalLesson if the publication type is course it contains total number of lesson included in Course. 
     * @param contentURI The URI to set for the content of publication (can be ipfs, arweave, http, etc).
     * @param pubType The type of publication, can be Nonexistent, Course, Lesson, Rating or Progress.
     * @param rootPubId The publication ID of the root post (to determine if rating/progress and lesson come from it).
     * @param rootProfileId The profile ID of the root post (to determine if rating/progress and lesson come from it).
     * @param collectModule The collect module used to collect the course(Only Applicable to CourseType publication).
     * @param certificateModule The certificate module used to provide cetificate to profileId once the course is completed(Only Applicable to CourseType publication).
     * @param actionModuleEnabled The action modules enabled in a given publication.
     */
    struct Publication {
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256 totalLesson;
        string contentURI;
        PublicationType pubType;
        uint256 rootProfileId;
        uint256 rootPubId;
        address collectModule;
        address certificateModule;
        mapping(address => bool) actionModuleEnabled;
    }

    struct PublicationMemory {
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256 totalLesson;
        string contentURI;
        PublicationType pubType;
        uint256 rootProfileId;
        uint256 rootPubId;
        address collectModule;
        address certificateModule;
    }

    /**
     * @notice A struct containing the parameters required for the `createProfile()` function.
     *
     * @param to The address receiving the profile.
     */
    struct CreateProfileParams {
        address to;
    }

    /**
     * @notice A struct containing the parameters required for the `course()` function.
     *
     * @param profileId The token ID of the profile to publish to.
     * @param contentURI The URI to set for this new publication.
     * @param certificateModule The certificate module used to provide cetificate to profileId once the course is completed(Only Applicable to CourseType publication).
     * @param collectModule The collect module used to collect the course(Only Applicable to CourseType publication).
     * @param collectModulesInitData The data to pass to the collect modules' initialization.
     */
    struct CourseParams {
        uint256 profileId;
        string contentURI;
        address certificateModule;
        address collectModule;
        bytes collectModulesInitData;
    }

    /**
     * @notice A struct containing the parameters required for the `lesson()` function.
     *
     * @param profileId The token ID of the profile to publish to.
     * @param contentURI The URI to set for this new publication.
     * @param pointedProfileId The profile token ID to point the lesson to.
     * @param pointedPubId The publication ID to point the lesson to.
     * @param actionModules The action modules to set for this new publication.
     * @param actionModulesInitDatas The data to pass to the action modules' initialization.
     */
    struct LessonParams {
        uint256 profileId;
        string contentURI;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        address[] actionModules;
        bytes[] actionModulesInitDatas;
    }

    /**
     * @notice A struct containing the parameters required for the `rating()` function.
     *
     * @param profileId The token ID of the profile to publish to.
     * @param contentURI The URI to set for this new publication.
     * @param pointedProfileId The profile token ID of the publication author that is rating.
     * @param pointedPubId The publication ID that is rating.
     */
    struct RatingParams {
        uint256 profileId;
        string contentURI;
        uint256 pointedProfileId;
        uint256 pointedPubId;
    }

    /**
     * @notice A struct containing the parameters required for the `progress()` function.
     *
     * @param profileId The token ID of the profile to publish to.
     * @param metadataURI the URI containing metadata attributes to attach to this progress publication.
     * @param pointedProfileId The profile token ID to point the progress to.
     * @param pointedPubId The publication ID to point the progress to.
     */
    struct ProgressParams {
        uint256 profileId;
        string metadataURI;
        uint256 pointedProfileId;
        uint256 pointedPubId;
    }

    /**
     * @notice A struct containing the parameters required for the `action()` function.
     *
     * @param publicationActedProfileId The token ID of the profile that published the publication to action.
     * @param publicationActedId The publication to action's publication ID.
     * @param actorProfileId The actor profile.
     * @param actionModuleAddress
     * @param actionModuleData The arbitrary data to pass to the actionModule if needed.
     */
    struct PublicationActionParams {
        uint256 publicationActedProfileId;
        uint256 publicationActedId;
        uint256 actorProfileId;
        address actionModuleAddress;
        bytes actionModuleData;
    }

    struct ProcessActionParams {
        uint256 publicationActedProfileId;
        uint256 publicationActedId;
        uint256 actorProfileId;
        address actorProfileOwner;
        address transactionExecutor;
        bytes actionModuleData;
    }

    struct ProcessLessonParams {
        uint256 profileId;
        uint256 pubId;
        address transactionExecutor;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        bytes data;
    }

    struct ProcessRatingParams {
        uint256 profileId;
        uint256 pubId;
        address transactionExecutor;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        bytes data;
    }

    struct ProcessProgressParams {
        uint256 profileId;
        uint256 pubId;
        address transactionExecutor;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        bytes data;
    }

    struct TreasuryData {
        address treasury;
        uint16 treasuryFeeBPS;
        mapping(address => uint256) treasuryFee;
    }

        /**
     * @notice A struct containing the parameters required for the `collect()` function.
     *
     * @param publicationCollectedProfileId The token ID of the profile that published the publication to collect.
     * @param publicationCollectedId The publication to collect's publication ID.
     * @param collectorProfileId The collector profile.
     * @param currency The currency used for collecting the course.
     * @param collectModuleAddress
     * @param collectModuleData The arbitrary data to pass to the collectModule if needed.
     */
    struct PublicationCollectParams {
        uint256 publicationCollectedProfileId;
        uint256 publicationCollectedId;
        uint256 collectorProfileId;
        address currency;
        address collectModuleAddress;
        bytes collectModuleData;
    }

    struct ProcessCollectParams {
        uint256 publicationCollectedProfileId;
        uint256 publicationCollectedId;
        uint256 collectorProfileId;
        address collectorProfileOwner;
        address transactionExecutor;
        bytes collectModuleData;
    }

}