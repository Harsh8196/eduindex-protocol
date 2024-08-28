// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IEduxGovernable} from '../interfaces/IEduxGovernable.sol';
import {GovernanceLib} from '../libraries/GovernanceLib.sol';
import {ValidationLib} from '../libraries/ValidationLib.sol';
import {StorageLib} from '../libraries/StorageLib.sol';
import {Types} from '../libraries/constants/Types.sol';
import {Events} from '../libraries/constants/Events.sol';

abstract contract EduxGovernable is IEduxGovernable {
    /**
     * @dev This modifier reverts if the caller is not the configured governance address.
     */
    modifier onlyGov() {
        ValidationLib.validateCallerIsGovernance();
        _;
    }

    /////////////////////////////////
    ///        GOV FUNCTIONS      ///
    /////////////////////////////////

    /// @inheritdoc IEduxGovernable
    function setGovernance(address newGovernance) external override onlyGov {
        GovernanceLib.setGovernance(newGovernance);
    }

    /// @inheritdoc IEduxGovernable
    function setEmergencyAdmin(address newEmergencyAdmin) external override onlyGov {
        GovernanceLib.setEmergencyAdmin(newEmergencyAdmin);
    }

    /// @inheritdoc IEduxGovernable
    function setState(Types.ProtocolState newState) external override {
        // Access control is handled inside the library because we need to check for both EmergencyAdmin and Governance.
        GovernanceLib.setState(newState);
    }

    /// @inheritdoc IEduxGovernable
    function setTreasury(address newTreasury) external override onlyGov {
        GovernanceLib.setTreasury(newTreasury);
    }

    /// @inheritdoc IEduxGovernable
    function setTreasuryFeeBPS(uint16 newTreasuryFee) external override onlyGov {
        GovernanceLib.setTreasuryFeeBPS(newTreasuryFee);
    }

    /// @inheritdoc IEduxGovernable
    function setTreasuryFee(uint256 newTreasuryFee, address currency) external override onlyGov {
        GovernanceLib.setTreasuryFee(newTreasuryFee,currency);
    }

    ///@inheritdoc IEduxGovernable
    function whitelistProfileCreator(address profileCreator, bool whitelist) external override onlyGov {
        GovernanceLib.whitelistProfileCreator(profileCreator, whitelist);
    }

    function setProfileTokenURIContract(address profileTokenURIContract) external override onlyGov {
        GovernanceLib.setProfileTokenURIContract(profileTokenURIContract);
        emit Events.BatchMetadataUpdate({fromTokenId: 0, toTokenId: type(uint256).max});
    }

    ///////////////////////////////////////////
    ///        EXTERNAL VIEW FUNCTIONS      ///
    ///////////////////////////////////////////

    /// @inheritdoc IEduxGovernable
    function getGovernance() external view override returns (address) {
        return StorageLib.getGovernance();
    }

    function getProfileTokenURIContract() external view override returns (address) {
        return StorageLib.getProfileTokenURIContract();
    }

    /**
     * @notice Returns the current protocol state.
     *
     * @return ProtocolState The Protocol state, an enum, where:
     *      0: Unpaused
     *      1: PublishingPaused
     *      2: Paused
     */
    function getState() external view override returns (Types.ProtocolState) {
        return StorageLib.getState();
    }

    /// @inheritdoc IEduxGovernable
    function getTreasury() external view override returns (address) {
        return StorageLib.getTreasuryData().treasury;
    }

    /// @inheritdoc IEduxGovernable
    function getTreasuryFeeBPS() external view override returns (uint16) {
        return StorageLib.getTreasuryData().treasuryFeeBPS;
    }

    /// @inheritdoc IEduxGovernable
    function getTreasuryFee(address currency) external view override returns (uint256) {
        return StorageLib.getTreasuryData().treasuryFee[currency];
    }

    /// @inheritdoc IEduxGovernable
    function getTreasuryData() external view override returns (address, uint16) {
        Types.TreasuryData storage treasuryData = StorageLib.getTreasuryData();
        return (treasuryData.treasury, treasuryData.treasuryFeeBPS);
    }

    /// @inheritdoc IEduxGovernable
    function isProfileCreatorWhitelisted(address profileCreator) external view override returns (bool) {
        return StorageLib.profileCreatorWhitelisted()[profileCreator];
    }


}