contract Owned {
    address public owner;
    function Owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function setOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
}
