contract TimelockedToken is StandardToken, Whitelist {
  uint256 lockedUntil;
  bool lockOverride = false;
  constructor() public {
    lockedUntil = now + 365 days;
  }
  modifier whenNotLocked() {
    require(lockOverride || now > lockedUntil);
    _;
  }
  function transfer(address _to, uint256 _value) public whenNotLocked returns (bool)
  {
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotLocked returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotLocked returns (bool)
  {
    return super.approve(_spender, _value);
  }
  function increaseApproval(address _spender, uint _addedValue) public whenNotLocked returns (bool)
  {
    return super.increaseApproval(_spender, _addedValue);
  }
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotLocked returns (bool)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
  function transferWhileLocked(address _to, uint256 _value) public onlyWhitelisted returns (bool)
  {
    return super.transfer(_to, _value);
  }
  function overrideLock(bool _overrideLock) public onlyOwner
  {
    lockOverride = _overrideLock;
  }
  function multiTransfer(address[] _receivers, uint256[] _amounts) public onlyWhitelisted {
    for (uint256 i = 0; i < _receivers.length; i++) {
      super.transfer(_receivers[i], _amounts[i] * 10 ** 18);
    }
  }
}
