// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import {Types} from '../libraries/constants/Types.sol';

/**
 * @title IEduxProtocol
 * @author Edux Protocol
 *
 * @notice This is the interface for Edux Protocol's core functions. It contains all the entry points for performing
 * social operations.
 */
interface IEduxProtocol {
    /**
     * @notice Creates a profile with the specified parameters, minting a Profile NFT to the given recipient.
     * @custom:permissions Any whitelisted profile creator.
     *
     * @param createProfileParams A CreateProfileParams struct containing the needed params.
     */
    function createProfile(Types.CreateProfileParams calldata createProfileParams) external returns (uint256);

    /**
     * @notice Sets the metadata URI for the given profile.
     * @custom:permissions Profile Owner.
     *
     * @param profileId The token ID of the profile to set the metadata URI for.
     * @param metadataURI The metadata URI to set for the given profile.
     */
    function setProfileMetadataURI(uint256 profileId, string calldata metadataURI) external;

    /**
     * @notice Publishes a course.
     * Course is the most basic publication type, and can be used to publish any kind of content.
     * Course can have these types of modules initialized:
     *  - Collect modules: Only One collect module based for collection of the course (Collecting by paying fee, or token gated etc)
     *
     * @param courseParams A CourseParams struct containing the needed parameters.
     *
     * @return uint256 An integer representing the course's publication ID.
     */
    function course(Types.CourseParams calldata courseParams) external returns (uint256);

    /**
     * @notice Publishes a lesson on the given course publication.
     * Lesson is a type of reference publication that points to another publication.
     * Lesson can have these types of modules initialized:
     *  - Action modules: any number of publication actions (e.g. token rewards, milestione base reward etc.)
     *
     * @param lessonParams A LessonParams struct containing the needed parameters.
     *
     * @return uint256 An integer representing the lesson's publication ID.
     */
    function lesson(Types.LessonParams calldata lessonParams) external returns (uint256);

    /**
     * @notice Publishes a rating of the given course publication.
     * Rating is a type of reference publication that points to another publication course
     * Rating don't have any modules initialized.
     * You can only rate the course once.
     *
     * @param ratingParams A RatingParams struct containing the necessary parameters.
     *
     * @return uint256 An integer representing the rating's publication ID.
     */
    function rating(Types.RatingParams calldata ratingParams) external returns (uint256);


    /**
     * @notice Publishes a progress of the lesson publication.
     * Progress is a type of reference publication that points to lesson publication
      * You can only submit the progress on the lesson once.
     *
     * @param progressParams A ProgressParams struct containing the needed parameters.
     *
     * @return uint256 An integer representing the progress's publication ID.
     */

    function bulkprogress(Types.ProgressParams[] calldata progressParams) external returns (uint256[] memory);

    /**
     * @notice Acts on a given publication with the specified parameters.
     * You can act on a lesson publication (if it has at least one action module initialized).
     *
     * @param publicationActionParams A PublicationActionParams struct containing the parameters.
     *
     * @return bytes Arbitrary data the action module returns.
     */
    function act(Types.PublicationActionParams calldata publicationActionParams) external returns (bytes memory);

    /**
     * @notice Collect on a given publication with the specified parameters.
     * You can collect course publication.
     *
     * @param publicationCollectParams A PublicationCollectParams struct containing the parameters.
     *
     * @return bytes Arbitrary data the action module returns.
     */
    function collect(Types.PublicationCollectParams calldata publicationCollectParams) external payable returns (bytes memory);

    /**
     * @notice completeCourse for completed course with the specified parameters.
     *
     * @param profileId The token ID of the profile.
     *
     * @param pointedProfileId The token ID of the publication's profile.
     *
     * @param pointedPublication The course publication id.
     *
     * @return uint256 TokenId for received NFT certificate
     */
    function completeCourse(uint256 profileId, uint256 pointedProfileId, uint256 pointedPublication) external returns (uint256);

    /////////////////////////////////
    ///       VIEW FUNCTIONS      ///
    /////////////////////////////////

    /**
     * @notice Returns the URI associated with a given publication.
     * This is used to store the publication's metadata, e.g.: content, images, etc.
     *
     * @param profileId The token ID of the profile that published the publication to query.
     * @param pubId The publication ID of the publication to query.
     *
     * @return string The URI associated with a given publication.
     */
    function getContentURI(uint256 profileId, uint256 pubId) external view returns (string memory);

    /**
     * @notice Returns true if lesson is completed by profile on given lesson publication.
     *
     * @param profileId The token ID of the profile to query.
     *
     * @param pointedPubId The lesson publication id to query.
     *
     * @return true if lesson is completed by profile.
     */
    function isLessonCompleted(uint256 profileId, uint256 pointedPubId) external view returns (bool);

    /**
     * @notice Returns true if course is completed by profile on given course publication.
     *
     * @param profileId The token ID of the profile to query.
     *
     * @param pointedProfile The token ID of the publication's profile to query.
     *
     * @param pointedPubId The course publication id to query.
     *
     * @return true if course is completed by profile.
     */
    function isCourseCompleted(uint256 profileId, uint256 pointedProfile, uint256 pointedPubId) external view returns (bool);

    /**
     * @notice Returns the full profile struct associated with a given profile token ID.
     *
     * @param profileId The token ID of the profile to query.
     *
     * @return Profile The profile struct of the given profile.
     */
    function getProfile(uint256 profileId) external view returns (Types.ProfileMemory memory);

    /**
     * @notice Returns the full publication struct for a given publication.
     *
     * @param profileId The token ID of the profile that published the publication to query.
     * @param pubId The publication ID of the publication to query.
     *
     * @return Publication The publication struct associated with the queried publication.
     */
    function getPublication(uint256 profileId, uint256 pubId) external view returns (Types.PublicationMemory memory);

    /**
     * @notice Returns the type of a given publication.
     * The type can be one of the following (see PublicationType enum):
     * - Nonexistent
     * - Course
     * - Lesson
     * - Rating
     * - Progress
     *
     * @param profileId The token ID of the profile that published the publication to query.
     * @param pubId The publication ID of the publication to query.
     *
     * @return PublicationType The publication type of the queried publication.
     */
    function getPublicationType(uint256 profileId, uint256 pubId) external view returns (Types.PublicationType);

    /**
     * @notice Returns wether a given Action Module is enabled for a given publication.
     *
     * @param profileId The token ID of the profile that published the publication to query.
     * @param pubId The publication ID of the publication to query.
     * @param module The address of the Action Module to query.
     *
     * @return bool True if the Action Module is enabled for the queried publication, false if not.
     */
    function isActionModuleEnabledInPublication(
        uint256 profileId,
        uint256 pubId,
        address module
    ) external view returns (bool);

    /**
     * @notice Returns the address of the registry that stores all modules that are used by the Edux Protocol.
     *
     * @return address The address of the Module Registry contract.
     */
    function getModuleRegistry() external view returns (address);
}