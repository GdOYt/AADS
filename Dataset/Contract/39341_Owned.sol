contract Owned {
    function Owned() {
        owner = msg.sender;
    }
    address public owner;
    modifier onlyOwner { if (msg.sender == owner) _; }
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
    function execute(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.value(_value)(_data);
    }
}
