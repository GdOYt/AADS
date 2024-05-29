contract Owned {
    address public owner;
    event OwnershipTransfered(address indexed owner);
    constructor() public {
        owner = msg.sender;
        emit OwnershipTransfered(owner);
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
        emit OwnershipTransfered(owner);
    }
}
