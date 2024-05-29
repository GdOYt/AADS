contract VersionedToken is owned {
    address public upgradableContractAddress;
    constructor(address initialImplementation) public {
        upgradableContractAddress = initialImplementation;
    }
    function upgradeToken(address newImplementation) onlyOwner public {
        upgradableContractAddress = newImplementation;
    }
    function() public {
        address upgradableContractMem = upgradableContractAddress;
        bytes memory functionCall = msg.data;
        assembly {
            let functionCallSize := mload(functionCall)
            let functionCallDataAddress := add(functionCall, 0x20)
            let functionCallResult := delegatecall(gas, upgradableContractMem, functionCallDataAddress, functionCallSize, 0, 0)
            let freeMemAddress := mload(0x40)
            switch functionCallResult
            case 0 {
                revert(freeMemAddress, 0)
            }
            default {
                returndatacopy(freeMemAddress, 0x0, returndatasize)
                return (freeMemAddress, returndatasize)
            }
        }
    }
}
