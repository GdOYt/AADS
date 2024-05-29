contract CLASSYToken is AbstractToken {
  uint256 constant MAX_TOKEN_COUNT = 100000000 * (10**18);
  address private owner;
  mapping (address => bool) private frozenAccount;
  uint256 tokenCount = 0;
  bool frozen = false;
  function CLASSYToken () {
    owner = msg.sender;
  }
  function totalSupply() constant returns (uint256 supply) {
    return tokenCount;
  }
  string constant public name = "CLASSY";
  string constant public symbol = "CLASSY";
  uint8 constant public decimals = 18;
  function transfer(address _to, uint256 _value) returns (bool success) {
    require(!frozenAccount[msg.sender]);
	if (frozen) return false;
    else return AbstractToken.transfer (_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value)
    returns (bool success) {
	require(!frozenAccount[_from]);
    if (frozen) return false;
    else return AbstractToken.transferFrom (_from, _to, _value);
  }
  function approve (address _spender, uint256 _value)
    returns (bool success) {
	require(allowance (msg.sender, _spender) == 0 || _value == 0);
    return AbstractToken.approve (_spender, _value);
  }
  function createTokens(uint256 _value)
    returns (bool success) {
    require (msg.sender == owner);
    if (_value > 0) {
      if (_value > safeSub (MAX_TOKEN_COUNT, tokenCount)) return false;
      accounts [msg.sender] = safeAdd (accounts [msg.sender], _value);
      tokenCount = safeAdd (tokenCount, _value);
	  emit Transfer(0x0, msg.sender, _value);
	  return true;
    }
	  return false;
  }
  function setOwner(address _newOwner) {
    require (msg.sender == owner);
    owner = _newOwner;
  }
  function freezeTransfers () {
    require (msg.sender == owner);
    if (!frozen) {
      frozen = true;
      emit Freeze ();
    }
  }
  function unfreezeTransfers () {
    require (msg.sender == owner);
    if (frozen) {
      frozen = false;
      emit Unfreeze ();
    }
  }
  function refundTokens(address _token, address _refund, uint256 _value) {
    require (msg.sender == owner);
    require(_token != address(this));
    AbstractToken token = AbstractToken(_token);
    token.transfer(_refund, _value);
    emit RefundTokens(_token, _refund, _value);
  }
  function freezeAccount(address _target, bool freeze) {
      require (msg.sender == owner);
	  require (msg.sender != _target);
      frozenAccount[_target] = freeze;
      emit FrozenFunds(_target, freeze);
 }
  event Freeze ();
  event Unfreeze ();
  event FrozenFunds(address target, bool frozen);
  event RefundTokens(address _token, address _refund, uint256 _value);
}
