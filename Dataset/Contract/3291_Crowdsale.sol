contract Crowdsale is Presale, Pausable, CanReclaimToken, Whitelist {
  using SafeMath for uint256;
  address public whitelistAddress;
  address public wallet;  
  MiniMeToken public token;  
  uint256 private weiRaised = 0;  
  uint256 private cap = 0;  
  bool private publicSaleInitialized = false;
  bool private finalized = false;
  uint256 private tokensSold = 0;  
  uint256 private startTime;  
  uint256 private endTime;  
  uint256 public maxTokens;
  mapping(address => uint256) public contributions;  
  mapping(address => uint256) public investorCaps;  
  address[] public investors;  
  address[] public founders;  
  address[] public advisors;  
  VestingTrustee public trustee;
  address public reserveWallet;  
  struct Tier {
    uint256 rate;
    uint256 max;
  }
  uint public privateSaleTokensAvailable;
  uint public privateSaleTokensSold = 0;
  uint public publicTokensAvailable;
  uint8 public totalTiers = 0;  
  bool public tiersInitialized = false;
  uint256 public maxTiers = 6;  
  Tier[6] public tiers;  
  event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
  enum Stage { Preparing, Presale, PresaleFinished, PublicSale, Success, Finalized }
  function Crowdsale(
    uint256 _presaleStartTime,  
    uint256 _presaleDuration,  
    uint256 _presaleRate,  
    uint256 _presaleCap,  
    address erc20Token,  
    address _wallet,
    uint8 _tiers,
    uint256 _cap,
    address _reserveWallet)
    public
    Presale(_presaleStartTime, _presaleDuration, _presaleRate, _presaleCap)
    {
      require(_wallet != address(0));
      require(erc20Token != address(0));
      require(_tiers > 0 && _tiers <= maxTiers);
      require(_cap > 0);
      require(_reserveWallet != address(0));
      token = MiniMeToken(erc20Token);
      wallet = _wallet;
      totalTiers = _tiers;
      cap = _cap;
      reserveWallet = _reserveWallet;
      trustee = new VestingTrustee(erc20Token);
      maxTokens = 1000000000 * (10 ** 18);  
      privateSaleTokensAvailable = maxTokens.mul(22).div(100);
      publicTokensAvailable = maxTokens.mul(28).div(100);
      super.addAddressToWhitelist(msg.sender);
    }
  function() public payable {
    buyTokens(msg.sender, msg.value);
  }
  function getStage() public constant returns(Stage) {
    if (finalized) return Stage.Finalized;
    if (!tiersInitialized || !Presale.hasStarted()) return Stage.Preparing;
    if (!Presale.hasEnded()) return Stage.Presale;
    if (Presale.hasEnded() && !hasStarted()) return Stage.PresaleFinished;
    if (!hasEnded()) return Stage.PublicSale;
    if (hasEnded()) return Stage.Success;
    return Stage.Preparing;
  }
  modifier inStage(Stage _stage) {
    require(getStage() == _stage);
    _;
  }
  function initTiers(uint256[] rates, uint256[] totalWeis) public onlyWhitelisted returns(uint256) {
    require(token.controller() == address(this));
    require(!tiersInitialized);
    require(rates.length == totalTiers && rates.length == totalWeis.length);
    uint256 tierMax = 0;
    for (uint8 i=0; i < totalTiers; i++) {
      require(totalWeis[i] > 0 && rates[i] > 0);
      tierMax = tierMax.add(totalWeis[i]);
      tiers[i] = Tier({
        rate: rates[i],
        max: tierMax
      });
    }
    require(tierMax == cap);
    tiersInitialized = true;
    return tierMax;
  }
  function setCapForParticipants(address[] participants, uint256[] caps) onlyWhitelisted public  {
    require(participants.length <= 50 && participants.length == caps.length);
    for (uint8 i=0; i < participants.length; i++) {
      investorCaps[participants[i]] = caps[i];
    }
  }
  function addGrant(address assignee, uint256 value, bool isFounder) public onlyWhitelisted whenNotPaused {
    require(value > 0);
    require(assignee != address(0));
    uint256 start;
    uint256 cliff;
    uint256 vestingPercentage;
    uint256 initialTokens;
    if(isFounder) {
      start = now;
      cliff = start + 12*30 days;  
      vestingPercentage = 20;  
      founders.push(assignee);
    }
    else {
      initialTokens = value.mul(10).div(100);
      transferTokens(assignee, initialTokens);
      start = now;
      cliff = start + 6*30 days;   
      vestingPercentage = 15;  
      advisors.push(assignee);
    }
    uint256 end = now + 3 * 1 years;  
    uint256 installmentLength = 6 * 30 days;  
    bool revokable = true;
    transferTokens(trustee, value.sub(initialTokens));
    trustee.grant(assignee, value, start, cliff, end, installmentLength, vestingPercentage, initialTokens, revokable);
  }
  function finalize() public onlyWhitelisted inStage(Stage.Success) {
    require(!finalized);
    trustee.transferOwnership(msg.sender);
    token.enableTransfers(true);
    uint256 unsold = maxTokens.sub(token.totalSupply());
    transferTokens(reserveWallet, unsold);
    token.changeController(0x0);
    finalized = true;
  }
  function startPublicSale(uint _startTime, uint _duration) public onlyWhitelisted inStage(Stage.PresaleFinished) {
    require(_startTime >= now);
    require(_duration > 0);
    startTime = _startTime;
    endTime = _startTime + _duration * 1 days;
    publicSaleInitialized = true;
  }
  function totalWei() public constant returns(uint256) {
    uint256 presaleWei = super.totalWei();
    return presaleWei.add(weiRaised);
  }
  function totalPublicSaleWei() public constant returns(uint256) {
    return weiRaised;
  }
  function totalCap() public constant returns(uint256) {
    uint256 presaleCap = super.totalCap();
    return presaleCap.add(cap);
  }
  function totalTokens() public constant returns(uint256) {
    return tokensSold;
  }
  function buyTokens(address purchaser, uint256 value) internal  whenNotPaused returns(uint256) {
    require(value > 0);
    Stage stage = getStage();
    require(stage == Stage.Presale || stage == Stage.PublicSale);
    uint256 purchaseAmount = Math.min256(value, investorCaps[purchaser].sub(contributions[purchaser]));
    require(purchaseAmount > 0);
    uint256 numTokens;
    if (stage == Stage.Presale) {
      if (Presale.totalWei().add(purchaseAmount) > Presale.totalCap()) {
        purchaseAmount = Presale.capRemaining();
      }
      numTokens = Presale.buyTokens(purchaser, purchaseAmount);
    } else if (stage == Stage.PublicSale) {
      uint totalWei = weiRaised.add(purchaseAmount);
      uint8 currentTier = getTier(weiRaised);  
      if (totalWei >= cap) {  
        totalWei = cap;
        purchaseAmount = cap.sub(weiRaised);
      }
      if (totalWei <= tiers[currentTier].max) {
        numTokens = purchaseAmount.mul(tiers[currentTier].rate);
      } else {
        uint remaining = tiers[currentTier].max.sub(weiRaised);
        numTokens = remaining.mul(tiers[currentTier].rate);
        uint256 excess = totalWei.sub(tiers[currentTier].max);
        numTokens = numTokens.add(excess.mul(tiers[currentTier + 1].rate));
      }
      weiRaised = weiRaised.add(purchaseAmount);
    }
    require(tokensSold.add(numTokens) <= publicTokensAvailable);
    tokensSold = tokensSold.add(numTokens);
    forwardFunds(purchaser, purchaseAmount);
    transferTokens(purchaser, numTokens);
    if (value.sub(purchaseAmount) > 0) {
      msg.sender.transfer(value.sub(purchaseAmount));
    }
    TokenPurchase(purchaser, numTokens, purchaseAmount);
    return numTokens;
  }
  function forwardFunds(address purchaser, uint256 value) internal {
    if (contributions[purchaser] == 0) {
      investors.push(purchaser);
    }
    contributions[purchaser] = contributions[purchaser].add(value);
    wallet.transfer(value);
  }
  function changeEndTime(uint _endTime) public onlyWhitelisted {
    endTime = _endTime;
  }
  function changeFundsWallet(address _newWallet) public onlyWhitelisted {
    require(_newWallet != address(0));
    wallet = _newWallet;
  }
  function changeTokenController() onlyWhitelisted public {
    token.changeController(msg.sender);
  }
  function changeTrusteeOwner() onlyWhitelisted public {
    trustee.transferOwnership(msg.sender);
  }
  function changeReserveWallet(address _reserve) public onlyWhitelisted {
    require(_reserve != address(0));
    reserveWallet = _reserve;
  }
  function setWhitelistAddress(address _whitelist) public onlyWhitelisted {
    require(_whitelist != address(0));
    whitelistAddress = _whitelist;
  }
  function transferTokens(address to, uint256 value) internal {
    token.generateTokens(to, value);
  }
  function sendPrivateSaleTokens(address to, uint256 value) public whenNotPaused onlyWhitelisted {
    require(privateSaleTokensSold.add(value) <= privateSaleTokensAvailable);
    privateSaleTokensSold = privateSaleTokensSold.add(value);
    transferTokens(to, value);
  }
  function hasEnded() internal constant returns(bool) {
    return now > endTime || weiRaised >= cap;
  }
  function hasStarted() internal constant returns(bool) {
    return publicSaleInitialized && now >= startTime;
  }
  function getTier(uint256 _weiRaised) internal constant returns(uint8) {
    for (uint8 i = 0; i < totalTiers; i++) {
      if (_weiRaised < tiers[i].max) {
        return i;
      }
    }
    return totalTiers + 1;
  }
  function getCurrentTier() public constant returns(uint8) {
    return getTier(weiRaised);
  }
  function proxyPayment(address _owner) public payable returns(bool) {
    return true;
  }
  function onApprove(address _owner, address _spender, uint _amount) public returns(bool) {
    return true;
  }
  function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
    return true;
  }
  function getTokenSaleTime() public constant returns(uint256, uint256) {
    return (startTime, endTime);
  }
}
