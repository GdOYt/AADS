contract Owned {
    address owner;
    function Owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        if (msg.sender != owner)
            revert();
        _;
    }
}
