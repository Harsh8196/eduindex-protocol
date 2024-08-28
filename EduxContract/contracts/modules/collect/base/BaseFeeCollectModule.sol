// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {ModuleErrors} from '../../libraries/constants/ModuleErrors.sol';
import {ModuleTypes} from '../../libraries/constants/ModuleTypes.sol';
import {Types} from '../../../libraries/constants/Types.sol';
import {IEduxHub} from '../../../interfaces/IEduxHub.sol';
import {FeeModuleBase} from '../../FeeModuleBase.sol';
import {IPublicationCollectModule} from '../../../interfaces/IPublicationCollectModule.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';


/**
 * @title BaseFeeCollectModule
 * @author Edux Protocol
 *
 * @notice This is base Edux CollectModule implementation, allowing customization of time to collect and number of collects.
 * Charges a fee for collect and distributing it among Receiver/Treasury.
 * @dev Here we use "Base" terminology to anything that represents this base functionality (base structs,
 * base functions, base storage). Other collect modules can be built on top of the "Base" by inheriting from this
 * contract and overriding functions.
 * This contract is marked "abstract" as it requires you to implement initializePublicationCollectModule and
 * getPublicationData functions when you inherit from it. See SimpleFeeCollectModule as an example implementation.
 */
abstract contract BaseFeeCollectModule is FeeModuleBase {
    using SafeERC20 for IERC20;

    mapping(uint256 => mapping(uint256 => ModuleTypes.BaseFeeCollectCourse)) internal _baseFeeCollectForCourse;

    constructor(
        address hub,
        address moduleRegistry
    ) FeeModuleBase(hub, moduleRegistry) {}

    function supportsInterface(bytes4 interfaceID) public pure virtual returns (bool) {
        return interfaceID == type(IPublicationCollectModule).interfaceId;
    }

    function _calculateFee(
        Types.ProcessCollectParams calldata processCollectParams
    ) internal virtual returns (uint160) {
            ModuleTypes.BaseFeeCollectCourse memory _courseData = _baseFeeCollectForCourse[processCollectParams.publicationCollectedProfileId][processCollectParams.publicationCollectedId];
            return _courseData.amount;
    }

    function getBasePublicationData(
        uint256 profileId,
        uint256 pubId
    ) public view virtual returns (ModuleTypes.BaseFeeCollectCourse memory) {
        return _baseFeeCollectForCourse[profileId][pubId];
    }

    /**
     * @dev Validates the Base parameters like:
     * 1) Is the currency whitelisted
     * 2) Is the end of collects timestamp in valid range
     *
     * This should be called during creation of course
     *
     * @param baseInitData Module initialization data (see BaseFeeCollectCourse struct)
     */
    function _validateBaseInitData(ModuleTypes.BaseFeeCollectCourseInitData memory baseInitData) internal virtual {
        if (
            (baseInitData.amount == 0 && baseInitData.currency != address(0)) ||
            (baseInitData.amount != 0 && baseInitData.currency == address(0)) ||
            (baseInitData.endTimestamp != 0 && baseInitData.endTimestamp < block.timestamp)
        ) {
            revert ModuleErrors.InitParamsInvalid();
        }
        _verifyErc20Currency(baseInitData.currency);
    }

        /**
     * @dev Stores the initial module parameters
     *
     * This should be called during initializePublicationCollectModule()
     *
     * @param profileId The token ID of the profile publishing the publication.
     * @param pubId The publication ID.
     * @param baseInitData Module initialization data (see BaseFeeCollectModuleInitData struct)
     */
    function _storeBasePublicationCollectParameters(
        uint256 profileId,
        uint256 pubId,
        ModuleTypes.BaseFeeCollectCourseInitData memory baseInitData
    ) internal virtual {
        _baseFeeCollectForCourse[profileId][pubId].amount = baseInitData.amount;
        _baseFeeCollectForCourse[profileId][pubId].collectLimit = baseInitData.collectLimit;
        _baseFeeCollectForCourse[profileId][pubId].currency = baseInitData.currency;
        _baseFeeCollectForCourse[profileId][pubId].recipient = baseInitData.recipient;
        _baseFeeCollectForCourse[profileId][pubId].endTimestamp = baseInitData.endTimestamp;
    }

    /**
     * @dev Validates the collect action by checking that:
     * 1) the number of collects after the action doesn't surpass the collect limit (if enabled)
     * 2) the current block timestamp doesn't surpass the end timestamp (if enabled)
     *
     * This should be called during processCollect()
     */
    function _validateAndStoreCollect(Types.ProcessCollectParams calldata processCollectParams) internal virtual {
        ModuleTypes.BaseFeeCollectCourse storage _courseData = _baseFeeCollectForCourse[processCollectParams.publicationCollectedProfileId][processCollectParams.publicationCollectedId];
        uint96 collectsAfter = ++_courseData.currentCollects;

        uint256 endTimestamp = _courseData.endTimestamp;
        uint256 collectLimit = _courseData.collectLimit;

        if (collectLimit != 0 && collectsAfter > collectLimit) {
            revert ModuleErrors.MintLimitExceeded();
        }
        if (endTimestamp != 0 && block.timestamp > endTimestamp) {
            revert ModuleErrors.CollectExpired();
        }
    }

    /**
     * @dev Internal processing of a collect:
     *  1. Calculation of fees
     *  2. Validation that fees are what collector expected
     *  3. Transfer of fees to recipient(-s) and treasury
     *
     * @param processCollectParams Parameters of the collect
     */
    function _processCollect(Types.ProcessCollectParams calldata processCollectParams) internal virtual returns (bytes memory){
        ModuleTypes.BaseFeeCollectCourse storage _courseData = _baseFeeCollectForCourse[processCollectParams.publicationCollectedProfileId][processCollectParams.publicationCollectedId];
        
        uint256 amount = _calculateFee(processCollectParams);
        address currency = _courseData.currency;
        _validateDataIsExpected(processCollectParams.collectModuleData, currency, amount);

        (address treasury, uint16 treasuryFee) = _treasuryData();
        uint256 treasuryAmount = (amount * treasuryFee) / BPS_MAX;

        if (treasuryAmount > 0) {
            IERC20(currency).safeTransferFrom(processCollectParams.transactionExecutor, treasury, treasuryAmount);
        }
        
        // Send amount after treasury cut, to all recipients
        _transferToRecipients(processCollectParams, currency, amount - treasuryAmount);

        return abi.encode(processCollectParams.collectorProfileOwner, _courseData.recipient,amount - treasuryAmount);

    }

    /**
     * @dev Tranfers the fee to recipient(-s)
     *
     * Override this to add additional functionality (e.g. multiple recipients)
     *
     * @param processCollectParams Parameters of the collect
     * @param currency Currency of the transaction
     * @param amount Amount to transfer to recipient(-s)
     */
    function _transferToRecipients(
        Types.ProcessCollectParams calldata processCollectParams,
        address currency,
        uint256 amount
    ) internal virtual {
        ModuleTypes.BaseFeeCollectCourse storage _courseData = _baseFeeCollectForCourse[processCollectParams.publicationCollectedProfileId][processCollectParams.publicationCollectedId];
        address recipient = _courseData.recipient;

        if (amount > 0) {
            IERC20(currency).safeTransferFrom(processCollectParams.collectorProfileOwner, recipient, amount);
        }
    }
}