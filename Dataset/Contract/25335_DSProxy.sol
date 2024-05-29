contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache;   
    function DSProxy(address _cacheAddr) public {
        require(setCache(_cacheAddr));
    }
    function() public payable {
    }
    function execute(bytes _code, bytes _data)
        public
        payable
        returns (address target, bytes32 response)
    {
        target = cache.read(_code);
        if (target == 0x0) {
            target = cache.write(_code);
        }
        response = execute(target, _data);
    }
    function execute(address _target, bytes _data)
        public
        auth
        note
        payable
        returns (bytes32 response)
    {
        require(_target != 0x0);
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)       
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }
    function setCache(address _cacheAddr)
        public
        auth
        note
        returns (bool)
    {
        require(_cacheAddr != 0x0);         
        cache = DSProxyCache(_cacheAddr);   
        return true;
    }
}
