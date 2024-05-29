contract Example is Upgradeable {
    uint _value;
    function initialize() public {
        _sizes[bytes4(keccak256("getUint()"))] = 32;
    }
    function getUint() public view returns (uint) {
        return _value;
    }
    function setUint(uint value) public {
        _value = value;
    }
}
