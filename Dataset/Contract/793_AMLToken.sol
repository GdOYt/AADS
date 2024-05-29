contract AMLToken is BurnableCrowdsaleToken {
  event OwnerReclaim(address fromWhom, uint amount);
  function AMLToken(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable) public BurnableCrowdsaleToken(_name, _symbol, _initialSupply, _decimals, _mintable) {
  }
  function transferToOwner(address fromWhom) public onlyOwner {
    if (released) revert();
    uint amount = balanceOf(fromWhom);
    balances[fromWhom] = balances[fromWhom].sub(amount);
    balances[owner] = balances[owner].add(amount);
    Transfer(fromWhom, owner, amount);
    OwnerReclaim(fromWhom, amount);
  }
}
