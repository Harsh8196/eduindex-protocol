// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {IERC721Burnable} from '../interfaces/IERC721Burnable.sol';

import {EduxBaseERC721} from '../base/EduxBaseERC721.sol';
import {ProfileLib} from '../libraries/ProfileLib.sol';
import {StorageLib} from '../libraries/StorageLib.sol';
import {ValidationLib} from '../libraries/ValidationLib.sol';
import {IProfileTokenURI} from '../interfaces/IProfileTokenURI.sol';

import {Errors} from '../libraries/constants/Errors.sol';
import {Types} from '../libraries/constants/Types.sol';
import {Events} from '../libraries/constants/Events.sol';

import {Address} from '@openzeppelin/contracts/utils/Address.sol';

abstract contract EduxProfiles is EduxBaseERC721 {
    using Address for address;

    modifier whenNotPaused() {
        if (StorageLib.getState() == Types.ProtocolState.Paused) {
            revert Errors.Paused();
        }
        _;
    }

    modifier onlyProfileOwner(address expectedOwner, uint256 profileId) {
        ValidationLib.validateAddressIsProfileOwner(expectedOwner, profileId);
        _;
    }

    /**
     * @notice Burns a profile, this maintains the profile data struct.
     */
    function burn(
        uint256 tokenId
    ) public override(EduxBaseERC721) whenNotPaused onlyProfileOwner(msg.sender, tokenId) {
        _burn(tokenId);
    }

    /**
     * @notice Mint a profile, this maintains the profile data struct.
     */
    function mint(
        address to,
        uint256 tokenId
    ) internal whenNotPaused {
        _mint(to,tokenId);

        unchecked {
            ++StorageLib.balances()[to];
        }

        Types.TokenData storage _tokenData = StorageLib.getTokenData(tokenId);
        _tokenData.owner = to;
        _tokenData.mintTimestamp = mintTimestampOf(tokenId);
    }

    /**
     * @dev Overrides the ERC721 tokenURI function to return the associated URI with a given profile.
     */
    function tokenURI(uint256 tokenId) public view override(EduxBaseERC721) returns (string memory) {
        if (!_exists(tokenId)) {
            revert Errors.TokenDoesNotExist();
        }
        uint256 mintTimestamp = StorageLib.getTokenData(tokenId).mintTimestamp;
        return IProfileTokenURI(StorageLib.getProfileTokenURIContract()).getTokenURI(tokenId, mintTimestamp);
    }

    function approve(address to, uint256 tokenId) public override(EduxBaseERC721) {

        super.approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override(EduxBaseERC721) {
 
        super.setApprovalForAll(operator, approved);
    }


    function transferProfile(address from, address to, uint256 tokenId) external {
        //solhint-disable-next-line max-line-length
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert Errors.NotOwnerOrApproved();
        }

        if (!StorageLib.profileCreatorWhitelisted()[msg.sender]) {
            // Delegates can be maintained on transfers only when executed by whitelisted profile creators, which are
            // trusted entities, for the sake of a better onboarding UX.
            revert Errors.NotAllowed();
        }

        if (ownerOf(tokenId) != from) {
            revert Errors.InvalidOwner();
        }

        if (to == address(0)) {
            revert Errors.InvalidParameter();
        }

        super._beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        unchecked {
            --StorageLib.balances()[from];
            ++StorageLib.balances()[to];
        }

        StorageLib.getTokenData(tokenId).owner = to;

        emit Transfer(from, to, tokenId);
    }

}