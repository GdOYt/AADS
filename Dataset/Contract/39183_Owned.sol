contract Owned {
    address public owner;
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
    function Owned() {
        owner = msg.sender;
    }
}
