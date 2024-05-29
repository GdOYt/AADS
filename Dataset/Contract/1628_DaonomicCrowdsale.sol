contract DaonomicCrowdsale {
  using SafeMath for uint256;
  uint256 public weiRaised;
  event Purchase(address indexed buyer, address token, uint256 value, uint256 sold, uint256 bonus, bytes txId);
  event RateAdd(address token);
  event RateRemove(address token);
  function () external payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address _beneficiary) public payable {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);
    (uint256 tokens, uint256 left) = _getTokenAmount(weiAmount);
    uint256 weiEarned = weiAmount.sub(left);
    uint256 bonus = _getBonus(tokens);
    uint256 withBonus = tokens.add(bonus);
    weiRaised = weiRaised.add(weiEarned);
    _processPurchase(_beneficiary, withBonus);
    emit Purchase(
      _beneficiary,
      address(0),
        weiEarned,
      tokens,
      bonus,
      ""
    );
    _updatePurchasingState(_beneficiary, weiEarned, withBonus);
    _postValidatePurchase(_beneficiary, weiEarned);
    if (left > 0) {
      _beneficiary.transfer(left);
    }
  }
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
  }
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  ) internal;
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount,
    uint256 _tokens
  )
    internal
  {
  }
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256, uint256);
  function _getBonus(uint256 _tokens) internal view returns (uint256);
}
