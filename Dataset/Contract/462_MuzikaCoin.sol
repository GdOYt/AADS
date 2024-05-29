contract MuzikaCoin is MintableToken, Pausable {
  string public name = 'Muzika';
  string public symbol = 'MZK';
  uint8 public decimals = 18;
  event Burn(address indexed burner, uint256 value);
  constructor(uint256 initialSupply) public {
    totalSupply_ = initialSupply;
    balances[msg.sender] = initialSupply;
    emit Transfer(address(0), msg.sender, initialSupply);
  }
  function burn(uint256 _value) public onlyOwner {
    _burn(msg.sender, _value);
  }
  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
  function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));
    increaseApproval(_spender, _addedValue);
    require(
      ApprovalAndCallFallBack(_spender).receiveApproval(
        msg.sender,
        _addedValue,
        address(this),
        _data
      )
    );
    return true;
  }
  function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
    require(_to != address(this));
    transfer(_to, _value);
    require(
      TransferAndCallFallBack(_to).receiveToken(
        msg.sender,
        _value,
        address(this),
        _data
      )
    );
    return true;
  }
  function tokenDrain(ERC20 _token, uint256 _amount) public onlyOwner {
    _token.transfer(owner, _amount);
  }
}
