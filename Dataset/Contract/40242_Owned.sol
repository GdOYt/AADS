contract Owned {
    modifier noEther() {if (msg.value > 0) throw; _}
    modifier onlyOwner { if (msg.sender == owner) _ }
    function Owned() { owner = msg.sender;}
    address owner;
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
    function execute(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.value(_value)(_data);
    }
    function getOwner() noEther constant returns (address) {
        return owner;
    }
}
