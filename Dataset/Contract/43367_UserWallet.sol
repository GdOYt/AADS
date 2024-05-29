contract UserWallet is UserAuth, UserNote {
    event LogExecute(address target, uint srcNum, uint sessionNum);
    constructor() public {
        registry = msg.sender;
        owner = msg.sender;
    }
    function() external payable {}
    function execute(
        address _target,
        bytes memory _data,
        uint _src,
        uint _session
    ) 
        public
        payable
        note
        auth
        logicAuth(_target)
        returns (bytes memory response)
    {
        emit LogExecute(
            _target,
            _src,
            _session
        );
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize
            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)
            switch iszero(succeeded)
                case 1 {
                    revert(add(response, 0x20), size)
                }
        }
    }
}
