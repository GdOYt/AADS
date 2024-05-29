contract acl{
    enum Role {
        USER,
        ORACLE,
        ADMIN
    }
    mapping (address=> Role) permissions;
    constructor() public {
        permissions[msg.sender] = Role(2);
    }
    function setRole(uint8 rolevalue,address entity)external check(2){
        permissions[entity] = Role(rolevalue);
    }
    function getRole(address entity)public view returns(Role){
        return permissions[entity];
    }
    modifier check(uint8 role) {
        require(uint8(getRole(msg.sender)) == role);
        _;
    }
}
