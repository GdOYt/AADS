contract Gold is StandardToken, Claimable, AccessMint {
  string public constant name = "Gold";
  string public constant symbol = "G";
  uint8 public constant decimals = 18;
  event Mint(
    address indexed _to,
    uint256 indexed _tokenId
  );
  function mint(address _to, uint256 _amount) 
    onlyAccessMint
    public 
    returns (bool) 
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }
}
