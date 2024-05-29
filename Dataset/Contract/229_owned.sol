contract owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) onlyOwner public returns (bool success) {
        newOwner = _newOwner;
        return true;
    }
    function acceptOwnership() public returns (bool success) {
        require(msg.sender == newOwner);
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
        newOwner = address(0);
        return true;
    }
}
