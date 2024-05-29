contract ManagerProxy is ManagerProxyTarget {
    function ManagerProxy(address _controller, bytes32 _targetContractId) public Manager(_controller) {
        targetContractId = _targetContractId;
    }
    function() public payable {
        address target = controller.getContract(targetContractId);
        require(target > 0);
        assembly {
            let freeMemoryPtrPosition := 0x40
            let calldataMemoryOffset := mload(freeMemoryPtrPosition)
            mstore(freeMemoryPtrPosition, add(calldataMemoryOffset, calldatasize))
            calldatacopy(calldataMemoryOffset, 0x0, calldatasize)
            let ret := delegatecall(gas, target, calldataMemoryOffset, calldatasize, 0, 0)
            let returndataMemoryOffset := mload(freeMemoryPtrPosition)
            mstore(freeMemoryPtrPosition, add(returndataMemoryOffset, returndatasize))
            returndatacopy(returndataMemoryOffset, 0x0, returndatasize)
            switch ret
            case 0 {
                revert(returndataMemoryOffset, returndatasize)
            } default {
                return(returndataMemoryOffset, returndatasize)
            }
        }
    }
}
