contract AccessAdmin is Ownable {
  mapping (address => bool) adminContracts;
  mapping (address => bool) actionContracts;
  function setAdminContract(address _addr, bool _useful) public onlyOwner {
    require(_addr != address(0));
    adminContracts[_addr] = _useful;
  }
  modifier onlyAdmin {
    require(adminContracts[msg.sender]); 
    _;
  }
  function setActionContract(address _actionAddr, bool _useful) public onlyAdmin {
    actionContracts[_actionAddr] = _useful;
  }
  modifier onlyAccess() {
    require(actionContracts[msg.sender]);
    _;
  }
}
