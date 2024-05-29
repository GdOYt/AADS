contract WhitelistedAICrowdsale is TokenlessCrowdsale, Ownable {
  using SafeMath for uint256;
  mapping(address => bool) public accredited;
  mapping(address => uint256) public contributions;
  mapping(address => uint256) public caps;
  function isWhitelisted(address _beneficiary) public view returns (bool) {
    if (caps[_beneficiary] != 0) {
      return true;
    }
    return false;
  }
  function addToWhitelist(address _beneficiary, uint256 _cap, bool _accredited) external onlyOwner {
    caps[_beneficiary] = _cap;
    accredited[_beneficiary] = _accredited;
  }
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    caps[_beneficiary] = 0;
    accredited[_beneficiary] = false;
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(contributions[_beneficiary].add(_weiAmount) <= caps[_beneficiary]);
  }
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
    super._updatePurchasingState(_beneficiary, _weiAmount);
    contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
  }
}
