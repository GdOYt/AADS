contract Owned {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function Owned() public {
        owner = msg.sender;
    }
    function transferOwnership(address _owner) public onlyOwner {
        require(_owner != 0x0);
        owner = _owner;
    }
}
