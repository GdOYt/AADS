contract PausableToken is StandardToken, Pausable {
  mapping (address => bool) public frozenAccount;
  event FrozenFunds(address target, bool frozen);
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(!frozenAccount[msg.sender]);
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(!frozenAccount[_from]);
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
  function batchTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    require(!frozenAccount[msg.sender]);
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt).mul(_value);
    require(cnt > 0 && cnt <= 121);
    require(_value > 0 && balances[msg.sender] >= amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        require (_receivers[i] != 0x0);
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        Transfer(msg.sender, _receivers[i], _value);
    }
    return true;
  }
  function freezeAccount(address target, bool freeze) onlyOwner public {
    frozenAccount[target] = freeze;
    FrozenFunds(target, freeze);
  }
  function batchFreeze(address[] addresses, bool freeze) onlyOwner public {
    for (uint i = 0; i < addresses.length; i++) {
        frozenAccount[addresses[i]] = freeze;
        FrozenFunds(addresses[i], freeze);
    }
  }
}
