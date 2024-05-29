contract PricingStrategy {
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }
  function isSane(address crowdsale) public constant returns (bool) {
    return true;
  }
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}
