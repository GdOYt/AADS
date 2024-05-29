contract Proxy {
    function implementation() public view returns (address);
    function () payable public {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            mstore(0x40, add(ptr, returndatasize))
            returndatacopy(ptr, 0, returndatasize)
            switch result
            case 0 { revert(ptr, returndatasize) }
            default { return(ptr, returndatasize) }
        }
    }
}
