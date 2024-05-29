contract SecuredWithRoles is Owned {
    RolesI public roles;
    bytes32 public contractHash;
    bool public stopped = false;
    function SecuredWithRoles(string contractName_, address roles_) public {
        contractHash = keccak256(contractName_);
        roles = RolesI(roles_);
    }
    modifier stoppable() {
        require(!stopped);
        _;
    }
    modifier onlyRole(string role) {
        require(senderHasRole(role));
        _;
    }
    modifier roleOrOwner(string role) {
        require(msg.sender == owner || senderHasRole(role));
        _;
    }
    function hasRole(string roleName) public view returns (bool) {
        return roles.knownRoleNames(contractHash, keccak256(roleName));
    }
    function senderHasRole(string roleName) public view returns (bool) {
        return hasRole(roleName) && roles.roleList(contractHash, keccak256(roleName), msg.sender);
    }
    function stop() public roleOrOwner("stopper") {
        stopped = true;
    }
    function restart() public roleOrOwner("restarter") {
        stopped = false;
    }
    function setRolesContract(address roles_) public onlyOwner {
        require(this != address(roles));
        roles = RolesI(roles_);
    }
}
