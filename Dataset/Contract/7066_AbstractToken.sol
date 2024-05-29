contract AbstractToken is Token, SafeMath {
  function AbstractToken () public {
  }
  function balanceOf (address _owner) public view returns (uint256 balance) {
    return accounts [_owner];
  }
  function transfer (address _to, uint256 _value)
  public payable returns (bool success) {
    uint256 fromBalance = accounts [msg.sender];
    if (fromBalance < _value) return false;
    if (_value > 0 && msg.sender != _to) {
      accounts [msg.sender] = safeSub (fromBalance, _value);
      accounts [_to] = safeAdd (accounts [_to], _value);
    }
    Transfer (msg.sender, _to, _value);
    return true;
  }
  function transferFrom (address _from, address _to, uint256 _value)
  public payable returns (bool success) {
    uint256 spenderAllowance = allowances [_from][msg.sender];
    if (spenderAllowance < _value) return false;
    uint256 fromBalance = accounts [_from];
    if (fromBalance < _value) return false;
    allowances [_from][msg.sender] =
      safeSub (spenderAllowance, _value);
    if (_value > 0 && _from != _to) {
      accounts [_from] = safeSub (fromBalance, _value);
      accounts [_to] = safeAdd (accounts [_to], _value);
    }
    Transfer (_from, _to, _value);
    return true;
  }
  function approve (address _spender, uint256 _value)
  public payable returns (bool success) {
    allowances [msg.sender][_spender] = _value;
    Approval (msg.sender, _spender, _value);
    return true;
  }
  function allowance (address _owner, address _spender)
  public view returns (uint256 remaining) {
    return allowances [_owner][_spender];
  }
  mapping (address => uint256) internal accounts;
  mapping (address => mapping (address => uint256)) internal allowances;
}
