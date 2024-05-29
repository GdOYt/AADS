contract Crowdsale is Haltable {
  uint public constant TIME_PERIOD_IN_SEC = 1 days;
  uint public baseEthCap;
  uint public maxEthPerAddress;
  uint public MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE = 5;
  using SafeMath for uint;
  FractionalERC20 public token;
  PricingStrategy public pricingStrategy;
  FinalizeAgent public finalizeAgent;
  address public multisigWallet;
  uint public minimumFundingGoal;
  uint public startsAt;
  uint public endsAt;
  uint256 public tokensSold = 0;
  uint256 public weiRaised = 0;
  uint public presaleWeiRaised = 0;
  uint public investorCount = 0;
  uint public loadedRefund = 0;
  uint public weiRefunded = 0;
  bool public finalized;
  bool public requireCustomerId;
  bool public requiredSignedAddress;
  address public signerAddress;
  mapping (address => uint256) public investedAmountOf;
  mapping (address => uint256) public tokenAmountOf;
  uint public ownerTestValue;
  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}
  event Invested(address investor, uint256 weiAmount, uint256 tokenAmount, uint128 customerId);
  event Refund(address investor, uint weiAmount);
  event InvestmentPolicyChanged(bool newRequireCustomerId, bool newRequiredSignedAddress, address newSignerAddress);
  event EndsAtChanged(uint newEndsAt);
  event BaseEthCapChanged(uint newBaseEthCap);
  event MaxEthPerAddressChanged(uint newMaxEthPerAddress);
  function Crowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _baseEthCap, uint _maxEthPerAddress) {
    owner = msg.sender;
    baseEthCap = _baseEthCap;
    maxEthPerAddress = _maxEthPerAddress;
    token = FractionalERC20(_token);
    setPricingStrategy(_pricingStrategy);
    multisigWallet = _multisigWallet;
    if (multisigWallet == 0) {
        revert();
    }
    if (_start == 0) {
        revert();
    }
    startsAt = _start;
    if (_end == 0) {
        revert();
    }
    endsAt = _end;
    if (startsAt >= endsAt) {
        revert();
    }
    minimumFundingGoal = _minimumFundingGoal;
  }
  function() payable {
    buy();
  }
  function investInternal(address receiver, uint128 customerId) stopInEmergency private {
    uint weiAmount = msg.value;    
    uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised - presaleWeiRaised, tokensSold, msg.sender, token.decimals());
    if (tokenAmount == 0) {
      revert();
    }
    uint currentFgcCap = getCurrentFgcCap();
    if (tokenAmount > currentFgcCap) {
      revert();
    }
    if (investedAmountOf[receiver] == 0) {
       investorCount++;
    }
    investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].add(tokenAmount);    
    weiRaised = weiRaised.add(weiAmount);
    tokensSold = tokensSold.add(tokenAmount);
    if (pricingStrategy.isPresalePurchase(receiver)) {
        presaleWeiRaised = presaleWeiRaised.add(weiAmount);
    }
    if (isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold)) {
      revert();
    }
    assignTokens(receiver, tokenAmount);
    if (!multisigWallet.send(weiAmount)) 
      revert();
    Invested(receiver, weiAmount, tokenAmount, customerId);
  }
  function getCurrentFgcCap() public constant returns (uint) {
    if (block.timestamp < startsAt) 
      return maxEthPerAddress;
    uint timeSinceStart = block.timestamp.sub(startsAt);
    uint currentPeriod = timeSinceStart.div(TIME_PERIOD_IN_SEC).add(1);
    if (currentPeriod < 2) {
      return 5000 * 10**token.decimals();
    }
    if (currentPeriod > 2 && currentPeriod < 5) {
      return 1000 * 10**token.decimals();
    }
    if (currentPeriod > 4 && currentPeriod < 6) {
      return 500 * 10**token.decimals();
    }
    if (currentPeriod > 5 && currentPeriod < 9) {
      return 200 * 10**token.decimals();
    }
    if (currentPeriod > 8 && currentPeriod < 11) {
      return 100 * 10**token.decimals();
    }
    return maxEthPerAddress;
  }
  function preallocate(address receiver, uint256 fullTokens, uint256 weiPrice) public onlyOwner {
    uint256 tokenAmount = fullTokens;
    uint256 weiAmount = weiPrice * fullTokens;  
    weiRaised = weiRaised.add(weiAmount);
    tokensSold = tokensSold.add(tokenAmount);
    investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].add(tokenAmount);
    assignTokens(receiver, tokenAmount);
    Invested(receiver, weiAmount, tokenAmount, 0);
  }
  function investWithSignedAddress(address addr, uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {
     bytes32 hash = sha256(addr);
     if (ecrecover(hash, v, r, s) != signerAddress) 
      revert();
     if (customerId == 0) 
      revert();   
     investInternal(addr, customerId);
  }
  function investWithCustomerId(address addr, uint128 customerId) public payable {
    if (requiredSignedAddress) 
      revert();  
    if (customerId == 0) 
      revert();   
    investInternal(addr, customerId);
  }
  function invest(address addr) public payable {
    if (requireCustomerId) 
      revert();  
    if (requiredSignedAddress) 
      revert();  
    investInternal(addr, 0);
  }
  function buyWithSignedAddress(uint128 customerId, uint8 v, bytes32 r, bytes32 s) public payable {
    investWithSignedAddress(msg.sender, customerId, v, r, s);
  }
  function buyWithCustomerId(uint128 customerId) public payable {
    investWithCustomerId(msg.sender, customerId);
  }
  function buy() public payable {
    invest(msg.sender);
  }
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    if (finalized) {
      revert();
    }
    if (address(finalizeAgent) != 0) {
      finalizeAgent.finalizeCrowdsale();
    }
    finalized = true;
  }
  function setFinalizeAgent(FinalizeAgent addr) onlyOwner {
    finalizeAgent = addr;
    if (!finalizeAgent.isFinalizeAgent()) {
      revert();
    }
  }
  function setRequireCustomerId(bool value) onlyOwner {
    requireCustomerId = value;
    InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
  }
  function setRequireSignedAddress(bool value, address _signerAddress) onlyOwner {
    requiredSignedAddress = value;
    signerAddress = _signerAddress;
    InvestmentPolicyChanged(requireCustomerId, requiredSignedAddress, signerAddress);
  }
  function setBaseEthCap(uint _baseEthCap) onlyOwner {
    if (_baseEthCap == 0) 
      revert();
    baseEthCap = _baseEthCap;
    BaseEthCapChanged(baseEthCap);
  }
  function setMaxEthPerAddress(uint _maxEthPerAddress) onlyOwner {
    if(_maxEthPerAddress == 0)
      revert();
    maxEthPerAddress = _maxEthPerAddress;
    MaxEthPerAddressChanged(maxEthPerAddress);
  }
  function setEndsAt(uint time) onlyOwner {
    if (now > time) {
      revert();  
    }
    endsAt = time;
    EndsAtChanged(endsAt);
  }
  function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {
    pricingStrategy = _pricingStrategy;
    if (!pricingStrategy.isPricingStrategy()) {
      revert();
    }
  }
  function setMultisig(address addr) public onlyOwner {
    if (investorCount > MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE) {
      revert();
    }
    multisigWallet = addr;
  }
  function loadRefund() public payable inState(State.Failure) {
    if (msg.value == 0) 
      revert();
    loadedRefund = loadedRefund.add(msg.value);
  }
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0) 
      revert();
    investedAmountOf[msg.sender] = 0;
    weiRefunded = weiRefunded.add(weiValue);
    Refund(msg.sender, weiValue);
    if (!msg.sender.send(weiValue)) 
      revert();
  }
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= minimumFundingGoal;
  }
  function isFinalizerSane() public constant returns (bool sane) {
    return finalizeAgent.isSane();
  }
  function isPricingSane() public constant returns (bool sane) {
    return pricingStrategy.isSane(address(this));
  }
  function getState() public constant returns (State) {
    if (finalized) 
      return State.Finalized;
    else if (address(finalizeAgent) == 0) 
      return State.Preparing;
    else if (!finalizeAgent.isSane()) 
      return State.Preparing;
    else if (!pricingStrategy.isSane(address(this))) 
      return State.Preparing;
    else if (block.timestamp < startsAt) 
      return State.PreFunding;
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) 
      return State.Funding;
    else if (isMinimumGoalReached()) 
      return State.Success;
    else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) 
      return State.Refunding;
    else 
      return State.Failure;
  }
  function setOwnerTestValue(uint val) onlyOwner {
    ownerTestValue = val;
  }
  function isCrowdsale() public constant returns (bool) {
    return true;
  }
  modifier inState(State state) {
    if (getState() != state) 
      revert();
    _;
  }
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken);
  function isCrowdsaleFull() public constant returns (bool);
  function assignTokens(address receiver, uint tokenAmount) private;
}
