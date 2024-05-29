contract Owned {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    address public owner;
    function Owned() {
        owner = msg.sender;
    }
    address public newOwner;
    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
    function execute(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.value(_value)(_data);
    }
}
