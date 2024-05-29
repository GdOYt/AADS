contract Leader {
    address owner;
    mapping (address => bool) public admins;
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    modifier onlyAdmins() {
        require(admins[msg.sender]);
        _;
    }
    function setOwner (address _addr) onlyOwner() public {
        owner = _addr;
    }
    function addAdmin (address _addr) onlyOwner() public {
        admins[_addr] = true;
    }
    function removeAdmin (address _addr) onlyOwner() public {
        delete admins[_addr];
    }
}
