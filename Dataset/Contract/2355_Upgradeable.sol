contract Upgradeable {
    mapping(bytes4=>uint32) _sizes;
    address _dest;
    function initialize() public{
    }
    function replace(address target) internal {
        _dest = target;
        require(target.delegatecall(bytes4(keccak256("initialize()"))));
    }
}
