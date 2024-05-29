contract owned {
    address public owner;
    event OwnerChanged(address newOwner);
    modifier only_owner() {
        require(msg.sender == owner, "only_owner: forbidden");
        _;
    }
    modifier owner_or(address addr) {
        require(msg.sender == addr || msg.sender == owner, "!owner-or");
        _;
    }
    constructor() public {
        owner = msg.sender;
    }
    function setOwner(address newOwner) only_owner() external {
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }
}
