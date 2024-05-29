contract MintedTokenCappedCrowdsaleExt is CrowdsaleExt {
  uint public maximumSellableTokens;
  function MintedTokenCappedCrowdsaleExt(
    string _name, 
    address _token, 
    PricingStrategy _pricingStrategy, 
    address _multisigWallet, 
    uint _start, uint _end, 
    uint _minimumFundingGoal, 
    uint _maximumSellableTokens, 
    bool _isUpdatable, 
    bool _isWhiteListed
  ) CrowdsaleExt(_name, _token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal, _isUpdatable, _isWhiteListed) {
    maximumSellableTokens = _maximumSellableTokens;
  }
  event MaximumSellableTokensChanged(uint newMaximumSellableTokens);
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) public constant returns (bool limitBroken) {
    return tokensSoldTotal > maximumSellableTokens;
  }
  function isBreakingInvestorCap(address addr, uint tokenAmount) public constant returns (bool limitBroken) {
    assert(isWhiteListed);
    uint maxCap = earlyParticipantWhitelist[addr].maxCap;
    return (tokenAmountOf[addr].plus(tokenAmount)) > maxCap;
  }
  function isCrowdsaleFull() public constant returns (bool) {
    return tokensSold >= maximumSellableTokens;
  }
  function setMaximumSellableTokens(uint tokens) public onlyOwner {
    assert(!finalized);
    assert(isUpdatable);
    assert(now <= startsAt);
    CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
    assert(!lastTierCntrct.finalized());
    maximumSellableTokens = tokens;
    MaximumSellableTokensChanged(maximumSellableTokens);
  }
  function updateRate(uint newOneTokenInWei) public onlyOwner {
    assert(!finalized);
    assert(isUpdatable);
    assert(now <= startsAt);
    CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
    assert(!lastTierCntrct.finalized());
    pricingStrategy.updateRate(newOneTokenInWei);
  }
  function assignTokens(address receiver, uint tokenAmount) private {
    MintableTokenExt mintableToken = MintableTokenExt(token);
    mintableToken.mint(receiver, tokenAmount);
  }
}
