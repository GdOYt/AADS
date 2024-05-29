contract BurnableCrowdsaleToken is BurnableToken, CrowdsaleToken {
  function BurnableCrowdsaleToken(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable) public
    CrowdsaleToken(_name, _symbol, _initialSupply, _decimals, _mintable) {
  }
}
