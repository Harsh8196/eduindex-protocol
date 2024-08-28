// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Types} from '../libraries/constants/Types.sol';

library StorageLib {
    uint256 constant TOKEN_DATA_MAPPING_SLOT = 1;
    uint256 constant BALANCES_SLOT = 2;
    uint256 constant PROTOCOL_STATE_SLOT = 3;
    uint256 constant PROFILE_CREATOR_WHITELIST_MAPPING_SLOT = 4;
    uint256 constant PROFILES_MAPPING_SLOT = 5;
    uint256 constant PUBLICATIONS_MAPPING_SLOT = 6;
    uint256 constant PROFILE_COUNTER_SLOT = 7;
    uint256 constant GOVERNANCE_SLOT = 8;
    uint256 constant EMERGENCY_ADMIN_SLOT = 9;
    uint256 constant PROFILE_TOKEN_URI_CONTRACT_SLOT = 10;
    uint256 constant TREASURY_DATA_SLOT = 11;

    function getPublication(
        uint256 profileId,
        uint256 pubId
    ) internal pure returns (Types.Publication storage _publication) {
        assembly {
            mstore(0, profileId)
            mstore(32, PUBLICATIONS_MAPPING_SLOT)
            mstore(32, keccak256(0, 64))
            mstore(0, pubId)
            _publication.slot := keccak256(0, 64)
        }
    }

    function getPublicationMemory(
        uint256 profileId,
        uint256 pubId
    ) internal pure returns (Types.PublicationMemory memory) {
        Types.PublicationMemory storage _publicationStorage;
        assembly {
            mstore(0, profileId)
            mstore(32, PUBLICATIONS_MAPPING_SLOT)
            mstore(32, keccak256(0, 64))
            mstore(0, pubId)
            _publicationStorage.slot := keccak256(0, 64)
        }

        Types.PublicationMemory memory _publicationMemory;
        _publicationMemory = _publicationStorage;

        return _publicationMemory;
    }

    function getProfile(uint256 profileId) internal pure returns (Types.Profile storage _profiles) {
        assembly {
            mstore(0, profileId)
            mstore(32, PROFILES_MAPPING_SLOT)
            _profiles.slot := keccak256(0, 64)
        }
    }

    function getTokenData(uint256 tokenId) internal pure returns (Types.TokenData storage _tokenData) {
        assembly {
            mstore(0, tokenId)
            mstore(32, TOKEN_DATA_MAPPING_SLOT)
            _tokenData.slot := keccak256(0, 64)
        }
    }

    function balances() internal pure returns (mapping(address => uint256) storage _balances) {
        assembly {
            _balances.slot := BALANCES_SLOT
        }
    }

    function profileCreatorWhitelisted()
        internal
        pure
        returns (mapping(address => bool) storage _profileCreatorWhitelisted)
    {
        assembly {
            _profileCreatorWhitelisted.slot := PROFILE_CREATOR_WHITELIST_MAPPING_SLOT
        }
    }


    function getGovernance() internal view returns (address _governance) {
        assembly {
            _governance := sload(GOVERNANCE_SLOT)
        }
    }

    function setGovernance(address newGovernance) internal {
        assembly {
            sstore(GOVERNANCE_SLOT, newGovernance)
        }
    }

    function getEmergencyAdmin() internal view returns (address _emergencyAdmin) {
        assembly {
            _emergencyAdmin := sload(EMERGENCY_ADMIN_SLOT)
        }
    }

    function setEmergencyAdmin(address newEmergencyAdmin) internal {
        assembly {
            sstore(EMERGENCY_ADMIN_SLOT, newEmergencyAdmin)
        }
    }

    function getState() internal view returns (Types.ProtocolState _state) {
        assembly {
            _state := sload(PROTOCOL_STATE_SLOT)
        }
    }

    function setState(Types.ProtocolState newState) internal {
        assembly {
            sstore(PROTOCOL_STATE_SLOT, newState)
        }
    }

    function setProfileTokenURIContract(address profileTokenURIContract) internal {
        assembly {
            sstore(PROFILE_TOKEN_URI_CONTRACT_SLOT, profileTokenURIContract)
        }
    }

    function getProfileTokenURIContract() internal view returns (address _profileTokenURIContract) {
        assembly {
            _profileTokenURIContract := sload(PROFILE_TOKEN_URI_CONTRACT_SLOT)
        }
    }

    function getTreasuryData() internal pure returns (Types.TreasuryData storage _treasuryData) {
        assembly {
            _treasuryData.slot := TREASURY_DATA_SLOT
        }
    }
}