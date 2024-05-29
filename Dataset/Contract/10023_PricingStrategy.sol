contract PricingStrategy {
  address public tier;
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }
  function isSane(address crowdsale) public constant returns (bool) {
    return true;
  }
  function isPresalePurchase(address purchaser) public constant returns (bool) {
    return false;
  }
  function updateRate(uint newOneTokenInWei) public;
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}
