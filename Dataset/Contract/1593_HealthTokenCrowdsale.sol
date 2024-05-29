contract HealthTokenCrowdsale is AllowanceCrowdsale, HasNoTokens {
  constructor
    (
      uint256 _rate, 
      address _wallet,
      StandardToken _token,
      address _tokenWallet
    ) 
  public
    Crowdsale(_rate, _wallet, _token)
    AllowanceCrowdsale(_tokenWallet)
  {
    discount = 25;
    rate = _rate;
    volumeDiscounts.push(VolumeDiscount(10 ether, 5));
    volumeDiscounts.push(VolumeDiscount(50 ether, 10));
    volumeDiscounts.push(VolumeDiscount(100 ether, 15));
  }
  struct VolumeDiscount {
    uint256 volume;
    uint8 discount;
  }
  uint256 public rate;
  uint8 public discount;
  VolumeDiscount[] public volumeDiscounts;
  function setDiscount(uint8 _discount) external onlyOwner {
    discount = _discount;
  }
  function setRate(uint256 _rate) external onlyOwner {
    rate = _rate;
  }
  function addVolumeDiscount(uint256 _volume, uint8 _discount) external onlyOwner {
    volumeDiscounts.push(VolumeDiscount(_volume, _discount));
  }
  function clearVolumeDiscounts() external onlyOwner {
    delete volumeDiscounts;
  }
  function getVolumeDiscountsCount() public constant returns(uint) {
    return volumeDiscounts.length;
  }
  function _getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    uint256 tokensAmount = weiAmount.mul(rate);
    uint8 totalDiscount = discount;
    uint8 volumeDiscount = 0;
    for(uint i = 0; i < volumeDiscounts.length; i ++) {
      if(weiAmount >= volumeDiscounts[i].volume && volumeDiscount < volumeDiscounts[i].discount) {
        volumeDiscount = volumeDiscounts[i].discount;
      } 
    }
    totalDiscount = totalDiscount + volumeDiscount;
    if(totalDiscount > 0) {
      return tokensAmount / 100 * (100 + totalDiscount);
    }
    return tokensAmount;
  }
}
