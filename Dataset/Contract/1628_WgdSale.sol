contract WgdSale is WhitelistDaonomicCrowdsale, RefundableDaonomicCrowdsale {
  using SafeERC20 for WgdToken;
  event Buyback(address indexed addr, uint256 tokens, uint256 value);
  WgdToken public token;
  uint256 constant public FOR_SALE = 300000000000000000000000000;
  uint256 constant public MINIMAL_WEI = 500000000000000000;
  uint256 constant public END = 1541592000;
  uint256 constant STAGE1 = 20000000000000000000000000;
  uint256 constant STAGE2 = 60000000000000000000000000;
  uint256 constant STAGE3 = 140000000000000000000000000;
  uint256 constant STAGE4 = 300000000000000000000000000;
  uint256 constant RATE1 = 28000;
  uint256 constant RATE2 = 24000;
  uint256 constant RATE3 = 22000;
  uint256 constant RATE4 = 20000;
  uint256 constant BONUS_STAGE1 = 100000000000000000000000;
  uint256 constant BONUS_STAGE2 = 500000000000000000000000;
  uint256 constant BONUS_STAGE3 = 1000000000000000000000000;
  uint256 constant BONUS_STAGE4 = 5000000000000000000000000;
  uint256 constant BONUS1 = 1000000000000000000000;
  uint256 constant BONUS2 = 25000000000000000000000;
  uint256 constant BONUS3 = 100000000000000000000000;
  uint256 constant BONUS4 = 750000000000000000000000;
  uint256 public sold;
  constructor(WgdToken _token, Whitelist[] _whitelists)
  WhitelistDaonomicCrowdsale(_whitelists) public {
    token = _token;
    emit RateAdd(address(0));
  }
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  ) internal {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(_weiAmount >= MINIMAL_WEI);
  }
  function getRate(address _token) public view returns (uint256) {
    if (_token == address(0)) {
      (,, uint256 rate) = getStage(sold);
      return rate.mul(10 ** 18);
    } else {
      return 0;
    }
  }
  function buyback() public {
    (uint8 stage,,) = getStage(sold);
    require(stage > 0, "buyback doesn't work on stage 0");
    uint256 approved = token.allowance(msg.sender, this);
    uint256 inCirculation = token.totalSupply().sub(token.balanceOf(this));
    uint256 value = approved.mul(address(this).balance).div(inCirculation);
    token.burnFrom(msg.sender, approved);
    msg.sender.transfer(value);
    emit Buyback(msg.sender, approved, value);
  }
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  ) internal {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }
  function _getBonus(uint256 _tokens) internal view returns (uint256) {
    return getRealAmountBonus(FOR_SALE, sold, _tokens);
  }
  function getRealAmountBonus(uint256 _forSale, uint256 _sold, uint256 _tokens) public pure returns (uint256) {
    uint256 bonus = getAmountBonus(_tokens);
    uint256 left = _forSale.sub(_sold).sub(_tokens);
    if (left > bonus) {
      return bonus;
    } else {
      return left;
    }
  }
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256, uint256) {
    return getTokenAmount(sold, _weiAmount);
  }
  function getTokenAmount(uint256 _sold, uint256 _weiAmount) public view returns (uint256 tokens, uint256 left) {
    left = _weiAmount;
    while (left > 0) {
      (uint256 currentTokens, uint256 currentLeft) = getTokensForStage(_sold.add(tokens), left);
      if (left == currentLeft) {
        return (tokens, left);
      }
      left = currentLeft;
      tokens = tokens.add(currentTokens);
    }
  }
  function getTokensForStage(uint256 _sold, uint256 _weiAmount) public view returns (uint256 tokens, uint256 left) {
    (uint8 stage, uint256 limit, uint256 rate) = getStage(_sold);
    if (stage == 4) {
      return (0, _weiAmount);
    }
    if (stage == 0 && now > END) {
      revert("Sale is refundable, unable to buy");
    }
    tokens = _weiAmount.mul(rate);
    left = 0;
    (uint8 newStage,,) = getStage(_sold.add(tokens));
    if (newStage != stage) {
      tokens = limit.sub(_sold);
      uint256 weiSpent = (tokens.add(rate).sub(1)).div(rate);
      left = _weiAmount.sub(weiSpent);
    }
  }
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount,
    uint256 _tokens
  ) internal {
    super._updatePurchasingState(_beneficiary, _weiAmount, _tokens);
    sold = sold.add(_tokens);
  }
  function isRefundable() public view returns (bool) {
    (uint8 stage,,) = getStage(sold);
    return now > END && stage == 0;
  }
  function getStage(uint256 _sold) public pure returns (uint8 stage, uint256 limit, uint256 rate) {
    if (_sold < STAGE1) {
      return (0, STAGE1, RATE1);
    } else if (_sold < STAGE2) {
      return (1, STAGE2, RATE2);
    } else if (_sold < STAGE3) {
      return (2, STAGE3, RATE3);
    } else if (_sold < STAGE4) {
      return (3, STAGE4, RATE4);
    } else {
      return (4, 0, 0);
    }
  }
  function getAmountBonus(uint256 _tokens) public pure returns (uint256) {
    if (_tokens < BONUS_STAGE1) {
      return 0;
    } else if (_tokens < BONUS_STAGE2) {
      return BONUS1;
    } else if (_tokens < BONUS_STAGE3) {
      return BONUS2;
    } else if (_tokens < BONUS_STAGE4) {
      return BONUS3;
    } else {
      return BONUS4;
    }
  }
}
