// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import {Types} from './Types.sol';

library Events {
    /**
     * @dev Emitted when the NFT contract's name and symbol are set at initialization.
     *
     * @param name The NFT name set.
     * @param symbol The NFT symbol set.
     * @param timestamp The current block timestamp.
     */
    event BaseInitialized(string name, string symbol, uint256 timestamp);

    /**
     * @dev Emitted when the hub state is set.
     *
     * @param caller The caller who set the state.
     * @param prevState The previous protocol state, an enum of either `Paused`, `PublishingPaused` or `Unpaused`.
     * @param newState The newly set state, an enum of either `Paused`, `PublishingPaused` or `Unpaused`.
     * @param timestamp The current block timestamp.
     */
    event StateSet(
        address indexed caller,
        Types.ProtocolState indexed prevState,
        Types.ProtocolState indexed newState,
        uint256 timestamp
    );

    /**
     * @dev Emitted when the governance address is changed. We emit the caller even though it should be the previous
     * governance address.
     *
     * @param caller The caller who set the governance address.
     * @param prevGovernance The previous governance address.
     * @param newGovernance The new governance address set.
     * @param timestamp The current block timestamp.
     */
    event GovernanceSet(
        address indexed caller,
        address indexed prevGovernance,
        address indexed newGovernance,
        uint256 timestamp
    );

    /**
     * @dev Emitted when the emergency admin is changed. We emit the caller even though it should be the previous
     * governance address.
     *
     * @param caller The caller who set the emergency admin address.
     * @param oldEmergencyAdmin The previous emergency admin address.
     * @param newEmergencyAdmin The new emergency admin address set.
     * @param timestamp The current block timestamp.
     */
    event EmergencyAdminSet(
        address indexed caller,
        address indexed oldEmergencyAdmin,
        address indexed newEmergencyAdmin,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a profile creator is added to or removed from the whitelist.
     *
     * @param profileCreator The address of the profile creator.
     * @param whitelisted Whether or not the profile creator is being added to the whitelist.
     * @param timestamp The current block timestamp.
     */
    event ProfileCreatorWhitelisted(address indexed profileCreator, bool indexed whitelisted, uint256 timestamp);

    /**
     * @dev Emitted when a profile is created.
     *
     * @param profileId The newly created profile's token ID.
     * @param creator The profile creator, who created the token with the given profile ID.
     * @param to The address receiving the profile with the given profile ID.
     * @param timestamp The current block timestamp.
     */
    event ProfileCreated(uint256 indexed profileId, address indexed creator, address indexed to, uint256 timestamp);

    /**
     * @dev Emitted when a post is successfully published.
     *
     * @param courseParams The parameters passed to create the post publication.
     * @param pubId The publication ID assigned to the created post.
     * @param collectModulesInitReturnData The data returned from the collect modules' initialization for this given
     * publication. This is ABI-encoded and depends on the collect module chosen.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event CourseCreated(
        Types.CourseParams courseParams,
        uint256 indexed pubId,
        bytes collectModulesInitReturnData,
        address transactionExecutor,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a lesson is successfully published.
     *
     * @param lessonParams The parameters passed to create the lesson publication.
     * @param pubId The publication ID assigned to the created lesson.
     * @param actionModulesInitReturnDatas The data returned from the action modules' initialization for this given
     * publication. This is ABI-encoded and depends on the action module chosen.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event LessonCreated(
        Types.LessonParams lessonParams,
        uint256 indexed pubId,
        bytes[] actionModulesInitReturnDatas,
        address transactionExecutor,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a rating is successfully published.
     *
     * @param ratingParams The parameters passed to create the rating publication.
     * @param pubId The publication ID assigned to the created rating.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event RatingCreated(
        Types.RatingParams ratingParams,
        uint256 indexed pubId,
        address transactionExecutor,
        uint256 timestamp
    );

     /**
     * @dev Emitted when a progress is successfully published.
     *
     * @param progressParams The parameters passed to create the progress publication.
     * @param pubId The publication ID assigned to the created progress.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event ProgressCreated(
        Types.ProgressParams progressParams,
        uint256 indexed pubId,
        address transactionExecutor,
        uint256 timestamp
    );

    /**
     * @dev Emitted upon a successful action.
     *
     * @param publicationActionParams The parameters passed to act on a publication.
     * @param actionModuleReturnData The data returned from the action modules. This is ABI-encoded and the format
     * depends on the action module chosen.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event Acted(
        Types.PublicationActionParams publicationActionParams,
        bytes actionModuleReturnData,
        address transactionExecutor,
        uint256 timestamp
    );

    /**
     * @dev Emitted upon a successful collect.
     *
     * @param publicationCollectParams The parameters passed to collect on a publication.
     * @param collectModuleReturnData The data returned from the collect module. This is ABI-encoded and the format
     * depends on the collect module chosen.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event Collected(
        Types.PublicationCollectParams publicationCollectParams,
        bytes collectModuleReturnData,
        address transactionExecutor,
        uint256 timestamp
    );

    /**
     * @notice Emitted when the treasury address is set.
     *
     * @param prevTreasury The previous treasury address.
     * @param newTreasury The new treasury address set.
     * @param timestamp The current block timestamp.
     */
    event TreasurySet(address indexed prevTreasury, address indexed newTreasury, uint256 timestamp);

    /**
     * @notice Emitted when the treasury fee is set.
     *
     * @param prevTreasuryFee The previous treasury fee in BPS.
     * @param newTreasuryFee The new treasury fee in BPS.
     * @param timestamp The current block timestamp.
     */
    event TreasuryFeeSetBPS(uint16 indexed prevTreasuryFee, uint16 indexed newTreasuryFee, uint256 timestamp);

    event TreasuryFeeSet(uint256 indexed prevTreasuryFee, uint256 indexed newTreasuryFee, address indexed currency, uint256 timestamp);

    /**
     * @dev Emitted when the metadata associated with a profile is set in the `EduxPeriphery`.
     *
     * @param profileId The profile ID the metadata is set for.
     * @param metadata The metadata set for the profile and user.
     * @param transactionExecutor The address of the account that executed this operation.
     * @param timestamp The current block timestamp.
     */
    event ProfileMetadataSet(
        uint256 indexed profileId,
        string metadata,
        address transactionExecutor,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a collection's token URI is updated.
     * @param fromTokenId The ID of the smallest token that requires its token URI to be refreshed.
     * @param toTokenId The ID of the biggest token that requires its token URI to be refreshed. Max uint256 to refresh
     * all of them.
     */
    event BatchMetadataUpdate(uint256 fromTokenId, uint256 toTokenId);
}