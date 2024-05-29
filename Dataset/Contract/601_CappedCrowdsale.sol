contract CappedCrowdsale is StandardCrowdsale {
  using SafeMath for uint256;
  uint256 public cap;
  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }
  function validPurchase() internal returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return capReached;
  }
}
