contract Ownable {
    address public owner;
    address public newOwner;
    event OwnerUpdate(address _prevOwner, address _newOwner);
    constructor(address _owner) public {
        owner = _owner;
    }
    modifier ownerOnly {
        require(msg.sender == owner);
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
