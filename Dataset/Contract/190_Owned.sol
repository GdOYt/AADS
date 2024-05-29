contract Owned {
    address public owner;
    function Owned() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function setOwner(address _newOwner) onlyOwner {
	 if(_newOwner == 0x0)revert();
        owner = _newOwner;
    }
}
