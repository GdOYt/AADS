contract Owned is IOwned {
    address public owner;
    address public newOwner;
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
