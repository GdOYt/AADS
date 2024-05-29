contract ExtendedPrivateSale is TokenlessCrowdsale, WhitelistedAICrowdsale, FiatCappedCrowdsale, PausableCrowdsale {
  using SafeMath for uint256;
  RestrictedToken public tokenR0;  
  RestrictedToken public tokenR6;  
  uint8 constant bonusPct = 30;
  constructor (address _wallet, uint256 _millWeiRate) TokenlessCrowdsale(_wallet)
    FiatCappedCrowdsale(
      2000000 * (10 ** 3),  
      10000 * (10 ** 3),  
      (10 ** 18) / 50,  
      _millWeiRate
    )
  public {
    tokenR0 = new RestrictedToken(
      2 * 40000000 * (10 ** 18),  
      'Sparrow Token (Restricted)',  
      'SPX-R0',  
      18,  
      0,  
      msg.sender,  
      this  
    );
    tokenR6 = new RestrictedToken(
      2 * 52000000 * (10 ** 18),  
      'Sparrow Token (Restricted with 6-month vesting)',  
      'SPX-R6',  
      18,  
      6 * 30 * 86400,  
      msg.sender,  
      this  
    );
  }
  function _processPurchaseInWei(address _beneficiary, uint256 _weiAmount) internal {
    super._processPurchaseInWei(_beneficiary, _weiAmount);
    uint256 tokens = _toLeconte(_weiAmount);
    uint256 bonus = tokens.mul(bonusPct).div(100);
    if (accredited[_beneficiary]) {
      tokenR0.issue(_beneficiary, tokens);
      tokenR6.issue(_beneficiary, bonus);
    } else {
      tokenR6.issue(_beneficiary, tokens.add(bonus));
    }
  }
}
