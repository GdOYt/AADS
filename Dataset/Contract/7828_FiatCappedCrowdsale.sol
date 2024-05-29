contract FiatCappedCrowdsale is TokenlessCrowdsale, Ownable {
  using SafeMath for uint256;
  uint256 public millCap;  
  uint256 public millRaised;  
  uint256 public minMillPurchase;
  uint256 public millWeiRate;
  uint256 public millLeconteRate;
  uint256 constant minMillWeiRate = (10 ** 18) / (5000 * (10 ** 3));  
  uint256 constant maxMillWeiRate = (10 ** 18) / (100 * (10 ** 3));  
  uint256 constant minMillLeconteRate = (10 ** 18) / 1000;  
  uint256 constant maxMillLeconteRate = (10 ** 18) / 10;  
  modifier isSaneETHRate(uint256 _millWeiRate) {
    require(_millWeiRate >= minMillWeiRate);
    require(_millWeiRate <= maxMillWeiRate);
    _;
  }
  modifier isSaneSPXRate(uint256 _millLeconteRate) {
    require(_millLeconteRate >= minMillLeconteRate);
    require(_millLeconteRate <= maxMillLeconteRate);
    _;
  }
  constructor (
    uint256 _millCap,
    uint256 _minMillPurchase,
    uint256 _millLeconteRate,
    uint256 _millWeiRate
  ) public isSaneSPXRate(_millLeconteRate) isSaneETHRate(_millWeiRate) {
    require(_millCap > 0);
    require(_minMillPurchase > 0);
    millCap = _millCap;
    minMillPurchase = _minMillPurchase;
    millLeconteRate = _millLeconteRate;
    millWeiRate = _millWeiRate;
  }
  function capReached() public view returns (bool) {
    return millRaised >= millCap;
  }
  function setWeiRate(uint256 _millWeiRate) external onlyOwner isSaneETHRate(_millWeiRate) {
    millWeiRate = _millWeiRate;
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 _millAmount = _toMill(_weiAmount);
    require(_millAmount >= minMillPurchase);
    uint256 _millRaised = millRaised.add(_millAmount);
    require(_millRaised <= millCap);
    millRaised = _millRaised;
  }
  function _toMill(uint256 _weiAmount) internal returns (uint256) {
    return _weiAmount.div(millWeiRate);
  }
  function _toLeconte(uint256 _weiAmount) internal returns (uint256) {
    return _toMill(_weiAmount).mul(millLeconteRate);
  }
}
