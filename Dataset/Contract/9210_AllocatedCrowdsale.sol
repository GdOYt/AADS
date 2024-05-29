contract AllocatedCrowdsale is Crowdsale {
  address public beneficiary;
  function AllocatedCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, address _beneficiary, uint baseEthCap, uint maxEthPerAddress) 
    Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal, baseEthCap, maxEthPerAddress) {
    beneficiary = _beneficiary;
  }
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    if (tokenAmount > getTokensLeft()) {
      return true;
    } else {
      return false;
    }
  }
  function isCrowdsaleFull() public constant returns (bool) {
    return getTokensLeft() == 0;
  }
  function getTokensLeft() public constant returns (uint) {
    return token.allowance(owner, this);
  }
  function assignTokens(address receiver, uint256 tokenAmount) private {
    if (!token.transferFrom(beneficiary, receiver, tokenAmount)) 
      revert();
  }
}
