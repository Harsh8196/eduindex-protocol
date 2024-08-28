// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

// Interfaces
import {IEduxProtocol} from './interfaces/IEduxProtocol.sol';

// Constants
import {Types} from './libraries/constants/Types.sol';
import {Errors} from './libraries/constants/Errors.sol';

// Edux Hub Components
import {EduxHubStorage} from './base/EduxHubStorage.sol';
import {EduxGovernable} from './base/EduxGovernable.sol';
import {EduxProfiles} from './base/EduxProfiles.sol';

// Libraries
import {ActionLib} from './libraries/ActionLib.sol';
import {CollectLib} from './libraries/CollectLib.sol';
import {ProfileLib} from './libraries/ProfileLib.sol';
import {PublicationLib} from './libraries/PublicationLib.sol';
import {StorageLib} from './libraries/StorageLib.sol';
import {ValidationLib} from './libraries/ValidationLib.sol';
import {GovernanceLib} from './libraries/GovernanceLib.sol';

/**
 * @title EduxHub
 * @author Edux Protocol
 *
 * @notice This is the main entry point of the Edux Protocol. It contains governance functionality as well as
 * publishing and profile interaction functionality.
 *
 * NOTE: The Edux Protocol is unique in that frontend operators need to track a potentially overwhelming
 * number of NFT contracts and interactions at once. For that reason, we've made two quirky design decisions:
 *      1. Both Follow & Collect NFTs invoke a EduxHub callback on transfer with the sole purpose of emitting an event.
 *      2. Almost every event in the protocol emits the current block timestamp, reducing the need to fetch it manually.
 *
 * @custom:upgradeable Transparent upgradeable proxy. In this version, without initializer.
 * See `../misc/EduxHubInitializable.sol` for the initializable version.
 */
contract EduxHub is
    EduxProfiles,
    EduxGovernable,
    EduxHubStorage,
    IEduxProtocol
{
    address internal immutable MODULE_REGISTRY;
    modifier onlyOwnerOfProfile(address expectedOwner, uint256 profileId) {
        ValidationLib.validateAddressIsProfileOwner(expectedOwner, profileId);
        _;
    }

    modifier whenPublishingEnabled() {
        if (StorageLib.getState() != Types.ProtocolState.Unpaused) {
            revert Errors.PublishingPaused();
        }
        _;
    }

    constructor(
        address moduleRegistry,
        address newGovernance,
        string memory name, 
        string memory symbol
    )
        EduxProfiles()
        // EduxImplGetters(moduleRegistry,newGovernance)
    {
        MODULE_REGISTRY = moduleRegistry;
        GovernanceLib.initState(Types.ProtocolState.Paused);
        GovernanceLib.setGovernance(newGovernance);
        _initialize(name,symbol);
    }

    /// @inheritdoc IEduxProtocol
    function createProfile(
        Types.CreateProfileParams calldata createProfileParams
    ) external override whenNotPaused returns (uint256) {
        ValidationLib.validateProfileCreatorWhitelisted(msg.sender);
        unchecked {
            uint256 profileId = ++_profileCounter;
            mint(createProfileParams.to, profileId);
            ProfileLib.createProfile(createProfileParams, profileId);
            return profileId;
        }
    }

    ///////////////////////////////////////////
    ///        PROFILE OWNER FUNCTIONS      ///
    ///////////////////////////////////////////

    /// @inheritdoc IEduxProtocol
    function setProfileMetadataURI(
        uint256 profileId,
        string calldata metadataURI
    ) external override whenNotPaused onlyOwnerOfProfile(msg.sender, profileId) {
        ProfileLib.setProfileMetadataURI(profileId, metadataURI, msg.sender);
    }

    ////////////////////////////////////////
    ///        PUBLISHING FUNCTIONS      ///
    ////////////////////////////////////////

    /// @inheritdoc IEduxProtocol
    function course(
        Types.CourseParams calldata courseParams
    )
        external
        override
        whenPublishingEnabled
        onlyOwnerOfProfile(msg.sender, courseParams.profileId)
        returns (uint256)
    {
        return PublicationLib.course({courseParams: courseParams, transactionExecutor: msg.sender});
    }

    /// @inheritdoc IEduxProtocol
    function lesson(
        Types.LessonParams calldata lessonParams
    )
        external
        override
        whenPublishingEnabled
        onlyOwnerOfProfile(msg.sender, lessonParams.profileId)
        returns (uint256)
    {
        return PublicationLib.lesson({lessonParams: lessonParams, transactionExecutor: msg.sender});
    }

    /// @inheritdoc IEduxProtocol
    function rating(
        Types.RatingParams calldata ratingParams
    )
        external
        override
        whenPublishingEnabled
        onlyOwnerOfProfile(msg.sender, ratingParams.profileId)
        returns (uint256)
    {
        return PublicationLib.rating({ratingParams: ratingParams, transactionExecutor: msg.sender});
    }

    /// @inheritdoc IEduxProtocol
    function bulkprogress(
        Types.ProgressParams[] calldata progressParams
    )
        external
        override
        whenPublishingEnabled
        returns (uint256[] memory)
    {   
        return PublicationLib.bulkprogress({progressParams: progressParams, transactionExecutor: msg.sender});
    }


    /////////////////////////////////////////////////
    ///        PROFILE INTERACTION FUNCTIONS      ///
    /////////////////////////////////////////////////

    /// @inheritdoc IEduxProtocol
    function collect(
        Types.PublicationCollectParams calldata publicationCollectParams
    )
        external
        payable
        override
        whenNotPaused
        onlyOwnerOfProfile(msg.sender, publicationCollectParams.collectorProfileId)
        returns (bytes memory)
    {   
        ValidationLib.validateProtocolFeeIsCorrect(msg.value);
        payable(StorageLib.getTreasuryData().treasury).transfer(msg.value);

        return
            CollectLib.collect({
                publicationCollectParams: publicationCollectParams,
                transactionExecutor: msg.sender,
                collectorProfileOwner: ownerOf(publicationCollectParams.collectorProfileId)
            });
    }

    /// @inheritdoc IEduxProtocol
    function completeCourse(uint256 profileId, uint256 pointedProfileId, uint256 pointedPublication) 
    external
    override
    whenNotPaused
    onlyOwnerOfProfile(msg.sender, profileId)
    returns (uint256)
    {
        return 
            PublicationLib.completeCourse({
                profileId: profileId, 
                pointedProfileId: pointedProfileId, 
                pointedPublication: pointedPublication,
                transactionExecutor: msg.sender
            });
    }

    /// @inheritdoc IEduxProtocol
    function act(
        Types.PublicationActionParams calldata publicationActionParams
    )
        external
        override
        whenNotPaused
        onlyOwnerOfProfile(msg.sender, publicationActionParams.actorProfileId)
        returns (bytes memory)
    {
        return
            ActionLib.act({
                publicationActionParams: publicationActionParams,
                transactionExecutor: msg.sender,
                actorProfileOwner: ownerOf(publicationActionParams.actorProfileId)
            });
    }


    ///////////////////////////////////////////
    ///        EXTERNAL VIEW FUNCTIONS      ///
    ///////////////////////////////////////////

    /// @inheritdoc IEduxProtocol
    function getContentURI(uint256 profileId, uint256 pubId) external view override returns (string memory) {
        // This function is used by the Collect NFTs' tokenURI function.
        return PublicationLib.getContentURI(profileId, pubId);
    }

    /// @inheritdoc IEduxProtocol
    function isLessonCompleted(uint256 profileId, uint256 pointedPubId) external view override returns (bool) {
        return PublicationLib.isLessonCompleted(profileId, pointedPubId);
    }

    /// @inheritdoc IEduxProtocol
    function isCourseCompleted(uint256 profileId, uint256 pointedProfile, uint256 pointedPubId) external view override returns (bool) {
        return PublicationLib.isCourseCompleted(profileId, pointedProfile, pointedPubId);
    }

    /// @inheritdoc IEduxProtocol
    function getProfile(uint256 profileId) external view override returns (Types.ProfileMemory memory) {
        return _profiles[profileId];
    }

    /// @inheritdoc IEduxProtocol
    function getPublication(
        uint256 profileId,
        uint256 pubId
    ) external pure override returns (Types.PublicationMemory memory) {
        return StorageLib.getPublicationMemory(profileId, pubId);
    }

    /// @inheritdoc IEduxProtocol
    function isActionModuleEnabledInPublication(
        uint256 profileId,
        uint256 pubId,
        address module
    ) external view returns (bool) {
        return StorageLib.getPublication(profileId, pubId).actionModuleEnabled[module];
    }

    /// @inheritdoc IEduxProtocol
    function getPublicationType(
        uint256 profileId,
        uint256 pubId
    ) external view override returns (Types.PublicationType) {
        return PublicationLib.getPublicationType(profileId, pubId);
    }

    /// @inheritdoc IEduxProtocol
    function getModuleRegistry() external view override returns (address) {
        return MODULE_REGISTRY;
    }
}