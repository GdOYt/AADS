contract Authorized is AuthorizedList {
    function Authorized() public {
       authorized[msg.sender][I_AM_ROOT] = true;
    }
    modifier ifAuthorized(address _address, bytes32 _authorization) {
       require(authorized[_address][_authorization] || authorized[_address][I_AM_ROOT]);
       _;
    }
    function isAuthorized(address _address, bytes32 _authorization) public view returns (bool) {
       return authorized[_address][_authorization];
    }
    function toggleAuthorization(address _address, bytes32 _authorization) public ifAuthorized(msg.sender, I_AM_ROOT) {
       require(_address != msg.sender);
       if (_authorization == I_AM_ROOT && !authorized[_address][I_AM_ROOT])
           authorized[_address][STAFF_MEMBER] = false;
       authorized[_address][_authorization] = !authorized[_address][_authorization];
    }
}
