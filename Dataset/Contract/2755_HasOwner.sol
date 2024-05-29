contract HasOwner {
    address public owner;
    address public newOwner;
    constructor(address _owner) public {
        owner = _owner;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransfer(owner, newOwner);
        owner = newOwner;
    }
}
