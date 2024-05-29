contract CappedToken is MintableToken {
  uint256 public cap;
  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }
  function mint(
    address _to,
    uint256 _amount
  )
    canMint
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);
    return super.mint(_to, _amount);
  }
}
