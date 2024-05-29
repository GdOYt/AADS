contract SimpleDispatcher {
    address private target;
    function SimpleDispatcher(address _target) public {
        target = _target;
    }
    function () public payable {
        var dest = target;
        assembly {
            calldatacopy(0x0, 0x0, calldatasize)
            switch delegatecall(sub(gas, 10000), dest, 0x0, calldatasize, 0, 0)
            case 0 { revert(0, 0) }  
        }
    }
}
