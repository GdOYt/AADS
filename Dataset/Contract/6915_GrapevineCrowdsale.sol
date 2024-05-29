contract GrapevineCrowdsale is CappedCrowdsale, TimedCrowdsale, Pausable, RefundableCrowdsale, PostDeliveryCrowdsale {
  using SafeMath for uint256;
  TokenTimelockControllerInterface public timelockController;
  GrapevineWhitelistInterface  public authorisedInvestors;
  GrapevineWhitelistInterface public earlyInvestors;
  mapping(address => uint256) public bonuses;
  uint256 deliveryTime;
  uint256 tokensToBeDelivered;
  constructor(
    TokenTimelockControllerInterface _timelockController,
    GrapevineWhitelistInterface _authorisedInvestors,
    GrapevineWhitelistInterface _earlyInvestors,
    uint256 _rate, 
    address _wallet,
    ERC20 _token, 
    uint256 _openingTime, 
    uint256 _closingTime, 
    uint256 _softCap, 
    uint256 _hardCap)
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_hardCap)
    TimedCrowdsale(_openingTime, _closingTime) 
    RefundableCrowdsale(_softCap)
    public 
    {
    timelockController = _timelockController;
    authorisedInvestors = _authorisedInvestors;
    earlyInvestors = _earlyInvestors;
    deliveryTime = _closingTime.add(60*60*24*5);
  }
  function buyTokens(address _beneficiary, bytes _whitelistSign) public payable {
    if (!earlyInvestors.handleOffchainWhitelisted(_beneficiary, _whitelistSign)) {
      authorisedInvestors.handleOffchainWhitelisted(_beneficiary, _whitelistSign);
    }
    super.buyTokens(_beneficiary);
  }
  function withdrawTokens() public {
    require(goalReached());
    require(block.timestamp > deliveryTime);
    super.withdrawTokens();
    uint256 _bonusTokens = bonuses[msg.sender];
    if (_bonusTokens > 0) {
      bonuses[msg.sender] = 0;
      require(token.approve(address(timelockController), _bonusTokens));
      require(
        timelockController.createInvestorTokenTimeLock(
          msg.sender,
          _bonusTokens,
          deliveryTime,
          this
        )
      );
    }
  }
  function _processPurchase( address _beneficiary, uint256 _tokenAmount ) internal {
    uint256 _totalTokens = _tokenAmount;
    uint256 _bonus = getBonus(block.timestamp, _beneficiary, msg.value);
    if (_bonus>0) {
      uint256 _bonusTokens = _tokenAmount.mul(_bonus).div(100);
      uint256 _currentBalance = token.balanceOf(this);
      require(_currentBalance >= _totalTokens.add(_bonusTokens));
      bonuses[_beneficiary] = bonuses[_beneficiary].add(_bonusTokens);
      _totalTokens = _totalTokens.add(_bonusTokens);
    }
    tokensToBeDelivered = tokensToBeDelivered.add(_totalTokens);
    super._processPurchase(_beneficiary, _tokenAmount);
  }
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
    require(authorisedInvestors.whitelist(_beneficiary) || earlyInvestors.whitelist(_beneficiary));
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }
  function getBonus(uint256 _time, address _beneficiary, uint256 _value) view internal returns (uint256 _bonus) {
    _bonus = 0;
    if ( (weiRaised.sub(_value) < goal) && earlyInvestors.whitelist(_beneficiary) ) {
      _bonus = 30;
    } else {
      if (_time < openingTime.add(7 days)) {
        _bonus = 15;
      } else if (_time < openingTime.add(14 days)) {
        _bonus = 10;
      } else if (_time < openingTime.add(21 days)) {
        _bonus = 8;
      } else {
        _bonus = 6;
      }
    }
    return _bonus;
  }
  function finalization() internal {
    if (goalReached()) {
      timelockController.activate();
      uint256 balance = token.balanceOf(this);
      uint256 remainingTokens = balance.sub(tokensToBeDelivered);
      if (remainingTokens>0) {
        BurnableTokenInterface(address(token)).burn(remainingTokens);
      }
    }
    Ownable(address(token)).transferOwnership(owner);
    super.finalization();
  }
}
