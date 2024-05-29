contract Presale is Whitelist {
  using SafeMath for uint256;
  uint256 private weiRaised;
  uint256 private startTime;
  uint256 private endTime;
  uint256 private rate;
  uint256 private cap;
  function Presale(uint256 _startTime, uint256 duration, uint256 _rate, uint256 _cap) public {
    require(_rate > 0);
    require(_cap > 0);
    require(_startTime >= now);
    require(duration > 0);
    rate = _rate;
    cap = _cap;
    startTime = _startTime;
    endTime = startTime + duration * 1 days;
    weiRaised = 0;
  }
  function totalWei() public constant returns(uint256) {
    return weiRaised;
  }
  function capRemaining() public constant returns(uint256) {
    return cap.sub(weiRaised);
  }
  function totalCap() public constant returns(uint256) {
    return cap;
  }
  function buyTokens(address purchaser, uint256 value) internal returns(uint256) {
    require(validPurchase(value));
    uint256 tokens = rate.mul(value);
    weiRaised = weiRaised.add(value);
    return tokens;
  }
  function hasEnded() internal constant returns(bool) {
    return now > endTime || weiRaised >= cap;
  }
  function hasStarted() internal constant returns(bool) {
    return now > startTime;
  }
  function validPurchase(uint256 value) internal view returns (bool) {
    bool withinCap = weiRaised.add(value) <= cap;
    return withinCap && withinPeriod();
  }
  function presaleRate() public view returns(uint256) {
    return rate;
  }
  function withinPeriod () private constant returns(bool) {
    return now >= startTime && now <= endTime;
  }
  function increasePresaleEndTime(uint _days) public onlyWhitelisted {
    endTime = endTime + _days * 1 days;
  }
  function getPresaleEndTime() public constant returns(uint) {
    return endTime;
  }
}
