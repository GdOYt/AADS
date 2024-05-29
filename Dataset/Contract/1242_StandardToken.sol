contract StandardToken is ERC20Token{
  string public version = "1.0";
  string public name = "Preserve One’s Health";
  string public symbol = "POH";
  uint8 public  decimals = 18;
  bool public transfersEnabled = true;
  modifier transable(){
      require(transfersEnabled);
      _;
  }
  function transfer(address _to, uint256 _value) transable public returns (bool) {
    require(_to != address(0));
    require(balanceOf[msg.sender]>_value);
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) transable public returns (bool) {
    require(_to != address(0));
    uint256 _allowance = allowance[_from][msg.sender];
    require (_value <= _allowance);
    require(balanceOf[_from]>_value);
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    allowance[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool) {
    require(allowance[msg.sender][_spender]==0);
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowance[msg.sender][_spender] += _addedValue;
    emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowance[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowance[msg.sender][_spender] = 0;
    } else {
      allowance[msg.sender][_spender] -= _subtractedValue;
    }
    emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
    return true;
  }
}
