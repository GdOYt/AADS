contract Dispatcher is Upgradeable {
    constructor (address target) public {
        replace(target);
    }
    function initialize() public {
        revert();
    }
    function() public {
        uint len;
        address target;
        bytes4 sig;
        assembly { sig := calldataload(0) }
        len = _sizes[sig];
        target = _dest;
        bool ret;
        assembly {
            calldatacopy(0x0, 0x0, calldatasize)
            ret:=delegatecall(sub(gas, 10000), target, 0x0, calldatasize, 0, len)
            return(0, len)
        }
        if (!ret) revert();
    }
}
