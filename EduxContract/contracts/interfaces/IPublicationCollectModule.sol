// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import {Types} from '../libraries/constants/Types.sol';

/**
 * @title IPublicationCollect
 * @author Edux Protocol
 *
 * @notice This is the standard interface for all Edux-compatible Course Publication Collects.
 * Publication collect modules allow users to execute course collection directly from a publication, like:
 *  - Course Collection.
 *  - Collecting Course Based on some rules.
 *  - Etc..
 */
interface IPublicationCollectModule {
    /**
     * @notice Initializes the collect module for the given publication being published with this Collect module.
     * @custom:permissions EduxHub.
     *
     * @param profileId The profile ID of the author publishing the content with this Publication Collect.
     * @param pubId The publication ID being published.
     * @param transactionExecutor The address of the transaction executor (e.g. for any funds to transferFrom).
     * @param data Arbitrary data passed from the user to be decoded by the Collect Module during initialization.
     *
     * @return bytes Any custom ABI-encoded data. This will be a EduxHub event params that can be used by
     * indexers or UIs.
     */
    function initializePublicationCollect(
        uint256 profileId,
        uint256 pubId,
        address transactionExecutor,
        bytes calldata data
    ) external returns (bytes memory);

    /**
     * @notice Processes the collect for a given publication. This includes the collect's logic and any monetary/token
     * operations.
     * @custom:permissions EduxHub.
     *
     * @param processCollectParams The parameters needed to execute the publication collect.
     *
     * @return bytes Any custom ABI-encoded data. This will be a EduxHub event params that can be used by
     * indexers or UIs.
     */
    function processPublicationCollect(Types.ProcessCollectParams calldata processCollectParams)
        external
        returns (bytes memory);
}