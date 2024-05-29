contract CrowdsaleBase is Haltable, Whitelist {
  uint public MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE = 5;
  using SafeMathLib for uint;
  FractionalERC20 public token;
  PricingStrategy public pricingStrategy;
  FinalizeAgent public finalizeAgent;
  address public multisigWallet;
  uint public minimumFundingGoal;
  uint public startsAt;
  uint public endsAt;
  uint public tokensSold = 0;
  uint public weiRaised = 0;
  uint public presaleWeiRaised = 0;
  uint public investorCount = 0;
  uint public loadedRefund = 0;
  uint public weiRefunded = 0;
  bool public finalized;
  mapping (address => uint256) public investedAmountOf;
  mapping (address => uint256) public tokenAmountOf;
  mapping (address => bool) public earlyParticipantWhitelist;
  uint public ownerTestValue;
  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}
  event Invested(address investor, uint weiAmount, uint tokenAmount, uint128 customerId);
  event Refund(address investor, uint weiAmount);
  event InvestmentPolicyChanged(bool newRequireCustomerId, bool newRequiredSignedAddress, address newSignerAddress);
  event Whitelisted(address addr, bool status);
  event EndsAtChanged(uint newEndsAt);
  function CrowdsaleBase(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal) {
    owner = msg.sender;
    token = FractionalERC20(_token);
    setPricingStrategy(_pricingStrategy);
    multisigWallet = _multisigWallet;
    if(multisigWallet == 0) {
        throw;
    }
    if(_start == 0) {
        throw;
    }
    startsAt = _start;
    if(_end == 0) {
        throw;
    }
    endsAt = _end;
    if(startsAt >= endsAt) {
        throw;
    }
    minimumFundingGoal = _minimumFundingGoal;
  }
  function investInternal(address receiver, uint128 customerId) stopInEmergency internal returns(uint tokensBought) {
    Whitelist dc;
    address contract_addr = 0x062e41d1037745dc203e8c1AAcA651B8d157Da96;
    dc = Whitelist(contract_addr);
    require (dc.whitelist(msg.sender));
    require (dc.whitelist(receiver));
    if(getState() == State.PreFunding) {
      if(!earlyParticipantWhitelist[receiver]) {
        throw;
      }
    } else if(getState() == State.Funding) {
    } else {
      throw;
    }
    uint weiAmount = msg.value;
    require(weiAmount >= minimumFundingGoal);
    uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised - presaleWeiRaised, tokensSold, msg.sender, token.decimals());
    require(tokenAmount != 0);
    if(investedAmountOf[receiver] == 0) {
       investorCount++;
    }
    investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);
    weiRaised = weiRaised.plus(weiAmount);
    tokensSold = tokensSold.plus(tokenAmount);
    if(pricingStrategy.isPresalePurchase(receiver)) {
        presaleWeiRaised = presaleWeiRaised.plus(weiAmount);
    }
    require(!isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold));
    assignTokens(receiver, tokenAmount);
    if(!multisigWallet.send(weiAmount)) throw;
    Invested(receiver, weiAmount, tokenAmount, customerId);
    return tokenAmount;
  }
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    if(finalized) {
      throw;
    }
    if(address(finalizeAgent) != 0) {
      finalizeAgent.finalizeCrowdsale();
    }
    finalized = true;
  }
  function setFinalizeAgent(FinalizeAgent addr) onlyOwner {
    finalizeAgent = addr;
    if(!finalizeAgent.isFinalizeAgent()) {
      throw;
    }
  }
  function setEndsAt(uint time) onlyOwner {
    if(now > time) {
      throw;  
    }
    if(startsAt > time) {
      throw;  
    }
    endsAt = time;
    EndsAtChanged(endsAt);
  }
  function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {
    pricingStrategy = _pricingStrategy;
    if(!pricingStrategy.isPricingStrategy()) {
      throw;
    }
  }
  function setMultisig(address addr) public onlyOwner {
    if(investorCount > MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE) {
      throw;
    }
    multisigWallet = addr;
  }
  function loadRefund() public payable inState(State.Failure) {
    if(msg.value == 0) throw;
    loadedRefund = loadedRefund.plus(msg.value);
  }
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0) throw;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = weiRefunded.plus(weiValue);
    Refund(msg.sender, weiValue);
    if (!msg.sender.send(weiValue)) throw;
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
    if(finalized) return State.Finalized;
    else if (address(finalizeAgent) == 0) return State.Preparing;
    else if (!finalizeAgent.isSane()) return State.Preparing;
    else if (!pricingStrategy.isSane(address(this))) return State.Preparing;
    else if (block.timestamp < startsAt) return State.PreFunding;
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
    else if (isMinimumGoalReached()) return State.Success;
    else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) return State.Refunding;
    else return State.Failure;
  }
  function setOwnerTestValue(uint val) onlyOwner {
    ownerTestValue = val;
  }
  function setEarlyParicipantWhitelist(address addr, bool status) onlyOwner {
    earlyParticipantWhitelist[addr] = status;
    Whitelisted(addr, status);
  }
  function isCrowdsale() public constant returns (bool) {
    return true;
  }
  modifier inState(State state) {
    if(getState() != state) throw;
    _;
  }
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken);
  function isCrowdsaleFull() public constant returns (bool);
  function assignTokens(address receiver, uint tokenAmount) internal;
}
