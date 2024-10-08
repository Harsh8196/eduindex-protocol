// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IModuleRegistry} from '../interfaces/IModuleRegistry.sol';
import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {IEduxModule} from '../modules/interfaces/IEduxModule.sol';

import {IPublicationActionModule} from '../interfaces/IPublicationActionModule.sol';
import {IPublicationCollectModule} from '../interfaces/IPublicationCollectModule.sol';

/**
 * @title ModuleRegistry
 * @author Edux Protocol
 * @notice A registry for modules and currencies
 */
contract ModuleRegistry is IModuleRegistry {
    bytes4 private constant Edux_MODULE_INTERFACE_ID = bytes4(keccak256(abi.encodePacked('Edux_MODULE')));

    event ModuleRegistered(
        address indexed moduleAddress,
        uint256 indexed moduleType,
        string metadata,
        uint256 timestamp
    );

    event erc20CurrencyRegistered(
        address indexed erc20CurrencyAddress,
        string name,
        string symbol,
        uint8 decimals,
        uint256 timestamp
    );

    event ModuleMetadataRefreshed(address indexed moduleAddress, string metadata, uint256 timestamp);

    error NotEduxModule();
    error ModuleDoesNotSupportType(uint256 moduleType);
    error ModuleNotRegistered();

    mapping(address moduleAddress => uint256 moduleTypesBitmap) internal _registeredModules;

    mapping(address erc20CurrencyAddress => bool) internal _registeredErc20Currencies;

    constructor() {}

    // Modules

    function verifyModule(address moduleAddress, uint256 moduleType) external returns (bool) {
        registerModule(moduleAddress, moduleType);
        return true;
    }

    function registerModule(address moduleAddress, uint256 moduleType) public returns (bool registrationWasPerformed) {
        // This will fail if moduleType is out of range for `IModuleRegistry.ModuleType`
        require(
            moduleType > 0 && moduleType <= uint256(type(IModuleRegistry.ModuleType).max),
            'Module Type out of bounds'
        );

        bool isAlreadyRegisteredAsThatType = _registeredModules[moduleAddress] & (1 << moduleType) != 0;
        if (isAlreadyRegisteredAsThatType) {
            return false;
        } else {
            if (!IEduxModule(moduleAddress).supportsInterface(Edux_MODULE_INTERFACE_ID)) {
                revert NotEduxModule();
            }

            validateModuleSupportsType(moduleAddress, moduleType);

            string memory metadata = IEduxModule(moduleAddress).getModuleMetadataURI();
            emit ModuleRegistered(moduleAddress, moduleType, metadata, block.timestamp);
            _registeredModules[moduleAddress] |= (1 << moduleType);
            return true;
        }
    }

    function validateModuleSupportsType(address moduleAddress, uint256 moduleType) internal view {
        bool supportsInterface;
        if (moduleType == uint256(IModuleRegistry.ModuleType.PUBLICATION_ACTION_MODULE)) {
            supportsInterface = IEduxModule(moduleAddress).supportsInterface(
                type(IPublicationActionModule).interfaceId
            );
        } else if (moduleType == uint256(IModuleRegistry.ModuleType.PUBLICATION_COLLECT_MODULE)) {
            supportsInterface = IEduxModule(moduleAddress).supportsInterface(type(IPublicationCollectModule).interfaceId);
        }

        if (!supportsInterface) {
            revert ModuleDoesNotSupportType(moduleType);
        }
    }

    function getModuleTypes(address moduleAddress) public view returns (uint256) {
        return _registeredModules[moduleAddress];
    }

    function isModuleRegistered(address moduleAddress) external view returns (bool) {
        return _registeredModules[moduleAddress] != 0;
    }

    function isModuleRegisteredAs(address moduleAddress, uint256 moduleType) public view returns (bool) {
        require(moduleType <= type(uint8).max);
        return _registeredModules[moduleAddress] & (1 << moduleType) != 0;
    }

    // Currencies

    function verifyErc20Currency(address currencyAddress) external returns (bool) {
        registerErc20Currency(currencyAddress);
        return true;
    }

    function registerErc20Currency(address currencyAddress) public returns (bool registrationWasPerformed) {
        bool isAlreadyRegistered = _registeredErc20Currencies[currencyAddress];
        if (isAlreadyRegistered) {
            return false;
        } else {
            uint8 decimals = IERC20Metadata(currencyAddress).decimals();
            string memory name = IERC20Metadata(currencyAddress).name();
            string memory symbol = IERC20Metadata(currencyAddress).symbol();

            emit erc20CurrencyRegistered(currencyAddress, name, symbol, decimals, block.timestamp);
            _registeredErc20Currencies[currencyAddress] = true;
            return true;
        }
    }

    function isErc20CurrencyRegistered(address currencyAddress) external view returns (bool) {
        return _registeredErc20Currencies[currencyAddress];
    }

    function emitModuleMetadataRefresh(address moduleAddress) external {
        if (_registeredModules[moduleAddress] == 0) {
            revert ModuleNotRegistered();
        }
        emit ModuleMetadataRefreshed(moduleAddress, IEduxModule(moduleAddress).getModuleMetadataURI(), block.timestamp);
    }
}