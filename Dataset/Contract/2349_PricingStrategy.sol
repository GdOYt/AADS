contract PricingStrategy {
  function isPricingStrategy() public pure  returns (bool) {
    return true;
  }
  function isSane() public pure returns (bool) {
    return true;
  }
  function isPresalePurchase(address purchaser) public pure returns (bool) {
    return false;
  }
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public pure returns (uint tokenAmount){
  }
}
