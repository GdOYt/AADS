contract FlatPricingExt is PricingStrategy, Ownable {
  using SafeMathLibExt for uint;
  uint public oneTokenInWei;
  event RateChanged(uint newOneTokenInWei);
  modifier onlyTier() {
    if (msg.sender != address(tier)) throw;
    _;
  }
  function setTier(address _tier) onlyOwner {
    assert(_tier != address(0));
    assert(tier == address(0));
    tier = _tier;
  }
  function FlatPricingExt(uint _oneTokenInWei) onlyOwner {
    require(_oneTokenInWei > 0);
    oneTokenInWei = _oneTokenInWei;
  }
  function updateRate(uint newOneTokenInWei) onlyTier {
    oneTokenInWei = newOneTokenInWei;
    RateChanged(newOneTokenInWei);
  }
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint) {
    uint multiplier = 10 ** decimals;
    return value.times(multiplier) / oneTokenInWei;
  }
}
