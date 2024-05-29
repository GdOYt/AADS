contract HOWToken is MintableToken, BurnableToken, PausableToken {
  constructor(address _owner, address _minter)
    StandardToken(
      "HOW Token",    
      "HOW",  
      18   
    )
    HasOwner(_owner)
    MintableToken(_minter)
    public
  {
  }
}
