// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface INFTCertificate {
    /**
     * @notice claimCertificate for completed course with the specified parameters.
     * You can claim Certificate for completed course publication.
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
    function claimCertificate(uint256 profileId, uint256 pointedProfileId, uint256 pointedPublication, address transactionExecutor) external returns (uint256);
}