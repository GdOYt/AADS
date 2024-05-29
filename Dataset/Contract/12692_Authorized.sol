contract Authorized is AuthorizedList {
    function Authorized() public {
       authorized[msg.sender][PRESIDENT] = true;
    }
    modifier ifAuthorized(address _address, bytes32 _authorization) {
       require(authorized[_address][_authorization] || authorized[_address][PRESIDENT], "Not authorized to access!");
       _;
    }
    function isAuthorized(address _address, bytes32 _authorization) public view returns (bool) {
       return authorized[_address][_authorization];
    }
    function toggleAuthorization(address _address, bytes32 _authorization) public ifAuthorized(msg.sender, PRESIDENT) {
       require(_address != msg.sender, "Cannot change own permissions.");
       if (_authorization == PRESIDENT && !authorized[_address][PRESIDENT])
           authorized[_address][STAFF_MEMBER] = false;
       authorized[_address][_authorization] = !authorized[_address][_authorization];
    }
}
