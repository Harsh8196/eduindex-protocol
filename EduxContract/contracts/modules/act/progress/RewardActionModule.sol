// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {ModuleTypes} from '../../libraries/constants/ModuleTypes.sol';
import {Types} from '../../../libraries/constants/Types.sol';
import {ModuleErrors} from '../../libraries/constants/ModuleErrors.sol';
import {ModuleEvents} from '../../libraries/constants/ModuleEvents.sol';
import {IPublicationActionModule} from '../../../interfaces/IPublicationActionModule.sol';
import {IEduxHub} from '../../../interfaces/IEduxHub.sol';
import {HubRestricted} from '../../../base/HubRestricted.sol';
import {EduxModuleMetadata} from '../../EduxModuleMetadata.sol';
import {EduxModule} from '../../EduxModule.sol';

/**
 * @title RewardActionModule
 * @dev Open Action Module for giving reward for completing lessons.
 */
contract RewardActionModule is
    IPublicationActionModule,
    HubRestricted,
    EduxModuleMetadata,
    ERC20
{
    uint256 private _totalPointSupply;
    mapping(address => uint256) private EduxPointsBalances;

    /**
     * @dev Mapping of reward receivers for lesson.
     */
    mapping(uint256 profileId => mapping(uint256 pubId => address rewardReceiver))
        internal _rewardReceivers;

    /**
     * @dev Mapping of reward init parameters.
     */
    mapping(uint256 pubProfileId => mapping(uint256 pubId => ModuleTypes.RewardModuleInitParams)) internal _rewardInitParams;

    /**
     * @dev Initializes the RewardActionModule contract.
     * @param hub Address of the EduxHub contract.
     * @param moduleRegistry Address of the ModuleRegistry contract.
     */
    constructor(
        address hub,
        address moduleRegistry,
        address moduleOwner
    )
        HubRestricted(hub)
        EduxModuleMetadata(moduleOwner)
        ERC20("Edux Points", "EDUXPT")
    {}

    /**
     * @dev Returns the reward receiver for lesson.
     * @param profileId ID of the profile.
     * @param pubId ID of the publication.
     * @return Address of the reward receiver.
     */
    function getRewardReceiver(
        uint256 profileId,
        uint256 pubId
    ) public view returns (address) {
        return _rewardReceivers[profileId][pubId];
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public pure virtual override(EduxModule) returns (bool) {
        return
            interfaceID == type(IPublicationActionModule).interfaceId || EduxModule.supportsInterface(interfaceID);
    }

    function initializePublicationAction(
        uint256 profileId,
        uint256 pubId,
        address /*transactionExecutor*/,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        (uint256 rewardAmount) = abi.decode(data, (uint256));

        if (rewardAmount == 0) {
            revert ModuleErrors.RewardAmountCannotBeZero();
        }

        _rewardInitParams[profileId][pubId].rewardAmount = rewardAmount;
        _rewardInitParams[profileId][pubId].publicationProfileId = profileId;
        _rewardInitParams[profileId][pubId].publicationId = pubId;

        emit ModuleEvents.PublicationRewardRegistered(profileId, pubId, rewardAmount);
        return data;
    }

    function processPublicationAction(
        Types.ProcessActionParams calldata params
    ) external override onlyHub returns (bytes memory) {
        
        // check if lesson is completed by profile or not
        if(!IEduxHub(HUB).isLessonCompleted(params.actorProfileId,params.publicationActedId)){
            revert ModuleErrors.LessonIsNotCompletedByProfile();
        }

        // check if the reward is already distributed to profile or not
        if(_rewardReceivers[params.actorProfileId][params.publicationActedId] != address(0)){
            revert ModuleErrors.ProfileIsAlreadyRewarded();
        }

        _rewardReceivers[params.actorProfileId][params.publicationActedId] = params.actorProfileOwner;
        EduxPointsBalances[params.actorProfileOwner] += _rewardInitParams[params.publicationActedProfileId][params.publicationActedId].rewardAmount;
        _totalPointSupply += _rewardInitParams[params.publicationActedProfileId][params.publicationActedId].rewardAmount;

        emit ModuleEvents.RewardDistributed(
            params.actorProfileOwner,
            params.publicationActedId,
            _rewardInitParams[params.publicationActedProfileId][params.publicationActedId].rewardAmount
        );

        emit Transfer(address(0), params.actorProfileOwner, _rewardInitParams[params.publicationActedProfileId][params.publicationActedId].rewardAmount);

        return abi.encode(params.actorProfileOwner, _rewardInitParams[params.publicationActedProfileId][params.publicationActedId].rewardAmount);
    }

    // *************************************** ERC20 compatibility & overrides ***************************************

    /**
     * @notice Retrieves the number of decimals for the Eduxp points.
     * @dev This function is an override of the ERC20 function, so that we can pass the 0 value.
     */
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    /**
     * @notice Retrieves the total supply of Eduxp points.
     * @dev This overrides the ERC20 function because we don't have access to `_totalSupply` and we aren't using the
     *  internal transfer method.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalPointSupply;
    }

    /**
     * @notice Retrieves the Eduxp points balance of an account.
     * @dev This overrides the ERC20 function because we don't have access to `_totalSupply` and we aren't using the
     *  internal transfer method.
     * @param account The account to retrieve the EDUXP points balance of
     * @return The EDUXP points balance of the account
     */
    function balanceOf(address account) public view override returns (uint256) {
        return EduxPointsBalances[account];
    }

    /**
     * @notice The override of the transfer method to prevent the EDUXP token from being transferred.
     * @dev This function will always revert as we don't allow EDUXP transfers.
     * @param recipient The recipient of the EDUXP points
     * @param amount The amount of EDUXP points to transfer
     * @return A boolean indicating if the transfer was successful
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        revert ModuleErrors.TransferNotAllowed();
    }

    /**
     * @notice The override of the transferFrom method to prevent the EDUXP token from being transferred.
     * @dev This function will always revert as we don't allow EDUXP transfers.
     * @param sender The sender of the EDUXP points
     * @param recipient The recipient of the EDUXP points
     * @param amount The amount of EDUXP points to transfer
     * @return A boolean indicating if the transfer was successful
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        revert ModuleErrors.TransferNotAllowed();
    }
}