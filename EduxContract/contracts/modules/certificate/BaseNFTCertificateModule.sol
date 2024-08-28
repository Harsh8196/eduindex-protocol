// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ModuleTypes} from '../libraries/constants/ModuleTypes.sol';
import {ModuleErrors} from '../libraries/constants/ModuleErrors.sol';
import {ModuleEvents} from '../libraries/constants/ModuleEvents.sol';
import {IEduxHub} from '../../interfaces/IEduxHub.sol';
import {INFTCertificate} from '../../interfaces/INFTCertificate.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {ERC721URIStorage} from '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Counters} from '@openzeppelin/contracts/utils/Counters.sol';

/**
 * @title BaseNFTCertificateModule
 * @dev BaseNFTCertificate Module give you basic idea for creating NFT Certificate Contract.
 */
contract BaseNFTCertificateModule is ERC721, ERC721URIStorage, INFTCertificate
{
    using Counters for Counters.Counter;
    address immutable HUB;
    Counters.Counter private _tokenIdCounter;
    string private _tokenURI;

    modifier onlyHub() {
        if (msg.sender != HUB) {
            revert ModuleErrors.NotHub();
        }
        _;
    }

    /**
     * @dev Initializes the BaseNFTCertificateModule contract.
     * @param hub Address of the EduxHub contract.
     * @param tokenuri URI of the NFT Token.
     */
    constructor(
        address hub,
        string memory tokenuri
    )
        ERC721('Edux Certificate', "EDUXT")
    {
        HUB = hub;
        _tokenURI = tokenuri;
        
    }

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
     * @return uint256 TokenId for received NFT certificate
     */
    function claimCertificate(uint256 profileId, uint256 pointedProfileId, uint256 pointedPublication, address transactionExecutor) 
    external  
    override 
    onlyHub
    returns (uint256) {
        uint256 tokenId;
        if(!IEduxHub(HUB).isCourseCompleted(profileId, pointedProfileId, pointedPublication))
        {
            revert ModuleErrors.CourseIsNotCompletedByProfile();    
        } 
        if(balanceOf(transactionExecutor) != 0){
            revert ModuleErrors.CertificateIsAlreadyClaimedByProfile();
        }
        
        tokenId = safeMint(transactionExecutor);

        emit ModuleEvents.CourseCompletedByProfile(
                transactionExecutor,
                profileId,
                pointedPublication,
                pointedProfileId,
                block.timestamp
            );
        
        emit ModuleEvents.CertificateIssuedToProfile(
                transactionExecutor,
                profileId,
                tokenId,
                pointedPublication,
                address(this),
                block.timestamp
            );

            return tokenId;

    }


    function safeMint(address to) internal returns(uint256){
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        return tokenId;
    }

    function _beforeTokenTransfer(
    address from, 
    address to, 
    uint256 tokenId,
    uint256 batchSize
    ) internal override virtual { 

    if( from != address(0) ) {
        revert ModuleErrors.TokenTransferIsBlock();
    }
    super._beforeTokenTransfer(from, to, tokenId, batchSize);  
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}