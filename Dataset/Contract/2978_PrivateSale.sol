contract PrivateSale is Crowdsale {
  uint256 public tokenCap = PRIVATESALE_TOKENCAP;
  uint256 public cap = tokenCap * DECIMALS_MULTIPLIER;
  uint256 public weiCap = tokenCap * PRIVATESALE_BASE_PRICE_IN_WEI;
  constructor(address _tokenAddress, uint256 _startTime, uint256 _endTime) public {
    startTime = _startTime;
    endTime = _endTime;
    ledToken = LedTokenInterface(_tokenAddress);
    assert(_tokenAddress != 0x0);
    assert(_startTime > 0);
    assert(_endTime > _startTime);
  }
  function() public payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address _beneficiary) public payable whenNotPaused whenNotFinalized {
    require(_beneficiary != 0x0);
    require(validPurchase());
    uint256 weiAmount = msg.value;
    require(weiAmount >= MIN_PURCHASE_OTHERSALES && weiAmount <= MAX_PURCHASE);
    uint256 priceInWei = PRIVATESALE_BASE_PRICE_IN_WEI;
    totalWeiRaised = totalWeiRaised.add(weiAmount);
    uint256 tokens = weiAmount.mul(DECIMALS_MULTIPLIER).div(priceInWei);
    tokensMinted = tokensMinted.add(tokens);
    require(tokensMinted < cap);
    contributors = contributors.add(1);
    ledToken.mint(_beneficiary, tokens);
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
    forwardFunds();
  }
  function finalize() public onlyOwner {
    require(paused);
    require(!finalized);
    surplusTokens = cap - tokensMinted;
    ledToken.mint(ledMultiSig, surplusTokens);
    ledToken.transferControl(owner);
    emit Finalized();
    finalized = true;
  }
  function getInfo() public view returns(uint256, uint256, string, bool,  uint256, uint256, uint256, 
  bool, uint256, uint256){
    uint256 decimals = 18;
    string memory symbol = "LED";
    bool transfersEnabled = ledToken.transfersEnabled();
    return (
      TOTAL_TOKENCAP,  
      decimals,  
      symbol,
      transfersEnabled,
      contributors,
      totalWeiRaised,
      tokenCap,  
      started,
      startTime,  
      endTime
    );
  }
}
