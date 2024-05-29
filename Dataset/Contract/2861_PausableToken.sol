contract PausableToken is TokenVesting, Pausable {
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }
  function batchTransfer(address[] _toList, uint256[] _tokensList) public whenNotPaused returns (bool) {
      return super.batchTransfer(_toList, _tokensList);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
  function release(address _beneficiary) public whenNotPaused{
    super.release(_beneficiary);
  }
}
