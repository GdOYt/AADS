contract GambioCrowdsale is CappedCrowdsale, OnlyWhiteListedAddresses {
  using SafeMath for uint256;
  struct TokenPurchaseRecord {
    uint256 timestamp;
    uint256 weiAmount;
    address beneficiary;
  }
  uint256 transactionId = 1;
  mapping(uint256 => TokenPurchaseRecord) pendingTransactions;
  mapping(uint256 => bool) completedTransactions;
  uint256 public referralPercentage;
  uint256 public individualCap;
  event TokenPurchaseRequest(
    uint256 indexed transactionId,
    address beneficiary,
    uint256 indexed timestamp,
    uint256 indexed weiAmount,
    uint256 tokensAmount
  );
  event ReferralTokensSent(
    address indexed beneficiary,
    uint256 indexed tokensAmount,
    uint256 indexed transactionId
  );
  event BonusTokensSent(
    address indexed beneficiary,
    uint256 indexed tokensAmount,
    uint256 indexed transactionId
  );
  constructor(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _icoHardCapWei,
    uint256 _referralPercentage,
    uint256 _rate,
    address _wallet,
    uint256 _privateWeiRaised,
    uint256 _individualCap,
    address _utilityAccount,
    uint256 _tokenCap,
    uint256[] _vestingData
  )
  public
  OnlyWhiteListedAddresses(_utilityAccount)
  CappedCrowdsale(_icoHardCapWei, _vestingData, _wallet)
  Crowdsale(_startTime, _endTime, _rate, _wallet, _privateWeiRaised, _tokenCap)
  {
    referralPercentage = _referralPercentage;
    individualCap = _individualCap;
  }
  function() external payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address beneficiary) public payable {
    require(!isFinalized);
    require(beneficiary == msg.sender);
    require(msg.value != 0);
    require(msg.value >= individualCap);
    uint256 weiAmount = msg.value;
    require(isWhiteListedAddress(beneficiary));
    require(validPurchase(weiAmount));
    weiRaised = weiRaised.add(weiAmount);
    uint256 _transactionId = transactionId;
    uint256 tokensAmount = weiAmount.mul(rate);
    pendingTransactions[_transactionId] = TokenPurchaseRecord(now, weiAmount, beneficiary);
    transactionId += 1;
    emit TokenPurchaseRequest(_transactionId, beneficiary, now, weiAmount, tokensAmount);
    forwardFunds();
  }
  function delayIcoEnd(uint256 newDate) public onlyOwner {
    require(newDate != 0);
    require(newDate > now);
    require(!hasEnded());
    require(newDate > endTime);
    endTime = newDate;
  }
  function increaseWeiRaised(uint256 amount) public onlyOwner {
    require(now < startTime);
    require(amount > 0);
    require(weiRaised.add(amount) <= hardCap);
    weiRaised = weiRaised.add(amount);
  }
  function decreaseWeiRaised(uint256 amount) public onlyOwner {
    require(now < startTime);
    require(amount > 0);
    require(weiRaised > 0);
    require(weiRaised >= amount);
    weiRaised = weiRaised.sub(amount);
  }
  function issueTokensMultiple(uint256[] _transactionIds, uint256[] bonusTokensAmounts) public onlyOwner {
    require(isFinalized);
    require(_transactionIds.length == bonusTokensAmounts.length);
    for (uint i = 0; i < _transactionIds.length; i++) {
      issueTokens(_transactionIds[i], bonusTokensAmounts[i]);
    }
  }
  function issueTokens(uint256 _transactionId, uint256 bonusTokensAmount) internal {
    require(completedTransactions[_transactionId] != true);
    require(pendingTransactions[_transactionId].timestamp != 0);
    TokenPurchaseRecord memory record = pendingTransactions[_transactionId];
    uint256 tokens = record.weiAmount.mul(rate);
    address referralAddress = referrals[record.beneficiary];
    token.mint(record.beneficiary, tokens);
    emit TokenPurchase(record.beneficiary, record.weiAmount, tokens, _transactionId);
    completedTransactions[_transactionId] = true;
    if (bonusTokensAmount != 0) {
      require(bonusTokensAmount != 0);
      token.mint(record.beneficiary, bonusTokensAmount);
      emit BonusTokensSent(record.beneficiary, bonusTokensAmount, _transactionId);
    }
    if (referralAddress != address(0)) {
      uint256 referralAmount = tokens.mul(referralPercentage).div(uint256(100));
      token.mint(referralAddress, referralAmount);
      emit ReferralTokensSent(referralAddress, referralAmount, _transactionId);
    }
  }
  function validPurchase(uint256 weiAmount) internal view returns (bool) {
    bool withinCap = weiRaised.add(weiAmount) <= hardCap;
    bool withinCrowdsaleInterval = now >= startTime && now <= endTime;
    return withinCrowdsaleInterval && withinCap;
  }
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
