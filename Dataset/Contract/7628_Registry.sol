contract Registry is Storage, Roles {
    address public logic_contract;
    function setLogicContract(address _c) public onlySuperAdmin returns (bool success){
        logic_contract = _c;
        return true;
    }
    function () payable public {
        address target = logic_contract;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, target, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            case 1 { return(ptr, size) }
        }
    }
}
