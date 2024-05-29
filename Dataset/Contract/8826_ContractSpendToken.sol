contract ContractSpendToken is StandardToken, Ownable {
  mapping (address => address) private contractToReceiver;
  function addContract(address _contractAdd, address _to) external onlyOwner returns (bool) {
    require(_contractAdd != address(0x0));
    require(_to != address(0x0));
    contractToReceiver[_contractAdd] = _to;
    return true;
  }
  function removeContract(address _contractAdd) external onlyOwner returns (bool) {
    contractToReceiver[_contractAdd] = address(0x0);
    return true;
  }
  function contractSpend(address _from, uint256 _value) public returns (bool) {
    address _to = contractToReceiver[msg.sender];
    require(_to != address(0x0));
    require(_value <= balances[_from]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function getContractReceiver(address _contractAdd) public view onlyOwner returns (address) {
    return contractToReceiver[_contractAdd];
  }
}
