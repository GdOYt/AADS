contract FDC is TokenTracker, Phased, StepFunction, Targets, Parameters {
  string public name;
  enum state {
    pause,          
    earlyContrib,   
    round0,         
    round1,         
    offChainReg,    
    finalization,   
    done            
  }
  mapping(uint => state) stateOfPhase;
  mapping(bytes32 => bool) memoUsed;
  address[] public donorList;  
  address[] public earlyContribList;  
  uint public weiPerCHF;       
  uint public totalWeiDonated; 
  mapping(address => uint) public weiDonated; 
  address public foundationWallet; 
  address public registrarAuth; 
  address public exchangeRateAuth; 
  address public masterAuth; 
  uint phaseOfRound0;
  uint phaseOfRound1;
  event DonationReceipt (address indexed addr,           
                         string indexed currency,        
                         uint indexed bonusMultiplierApplied,  
                         uint timestamp,                 
                         uint tokenAmount,               
                         bytes32 memo);                  
  event EarlyContribReceipt (address indexed addr,       
                             uint tokenAmount,           
                             bytes32 memo);              
  event BurnReceipt (address indexed addr,               
                     uint tokenAmountBurned);            
  function FDC(address _masterAuth, string _name)
    TokenTracker(earlyContribShare)
    StepFunction(round1EndTime-round1StartTime, round1InitialBonus, 
                 round1BonusSteps) 
  {
    name = _name;
    foundationWallet  = _masterAuth;
    masterAuth     = _masterAuth;
    exchangeRateAuth  = _masterAuth;
    registrarAuth  = _masterAuth;
    stateOfPhase[0] = state.earlyContrib; 
    addPhase(round0StartTime);      
    stateOfPhase[1] = state.round0;
    addPhase(round0EndTime);        
    stateOfPhase[2] = state.offChainReg;
    addPhase(round1StartTime);      
    stateOfPhase[3] = state.round1;
    addPhase(round1EndTime);        
    stateOfPhase[4] = state.offChainReg;
    addPhase(finalizeStartTime);    
    stateOfPhase[5] = state.finalization;
    addPhase(finalizeEndTime);      
    stateOfPhase[6] = state.done;
    phaseOfRound0 = 1;
    phaseOfRound1 = 3;
    setMaxDelay(phaseOfRound0 - 1, maxRoundDelay);
    setMaxDelay(phaseOfRound1 - 1, maxRoundDelay);
    setTarget(phaseOfRound0, round0Target);
    setTarget(phaseOfRound1, round1Target);
  }
  function getState() constant returns (state) {
    return stateOfPhase[getPhaseAtTime(now)];
  }
  function getMultiplierAtTime(uint time) constant returns (uint) {
    uint n = getPhaseAtTime(time);
    if (stateOfPhase[n] == state.round0) {
      return 100 + round0Bonus;
    }
    if (stateOfPhase[n] == state.round1) {
      return 100 + getStepFunction(time - getPhaseStartTime(n));
    }
    throw;
  }
  function donateAsWithChecksum(address addr, bytes4 checksum) 
    payable 
    returns (bool) 
  {
    bytes32 hash = sha256(addr);
    if (bytes4(hash) != checksum) { throw ; }
    return donateAs(addr);
  }
  function finalize(address addr) {
    if (getState() != state.finalization) { throw; }
    closeAssignmentsIfOpen(); 
    uint tokensBurned = unrestrict(addr); 
    BurnReceipt(addr, tokensBurned);
    if (isUnrestricted()) { 
      endCurrentPhaseIn(0); 
    }
  }
  function empty() returns (bool) {
    return foundationWallet.call.value(this.balance)();
  }
  function getStatus(uint donationRound, address dfnAddr, address fwdAddr)
    public constant
    returns (
      state currentState,      
      uint fxRate,             
      uint currentMultiplier,  
      uint donationCount,      
      uint totalTokenAmount,   
      uint startTime,          
      uint endTime,            
      bool isTargetReached,    
      uint chfCentsDonated,    
      uint tokenAmount,        
      uint fwdBalance,         
      uint donated)            
  {
    currentState = getState();
    if (currentState == state.round0 || currentState == state.round1) {
      currentMultiplier = getMultiplierAtTime(now);
    } 
    fxRate = weiPerCHF;
    donationCount = totalUnrestrictedAssignments;
    totalTokenAmount = totalUnrestrictedTokens;
    if (donationRound == 0) {
      startTime = getPhaseStartTime(phaseOfRound0);
      endTime = getPhaseStartTime(phaseOfRound0 + 1);
      isTargetReached = targetReached(phaseOfRound0);
      chfCentsDonated = counter[phaseOfRound0];
    } else {
      startTime = getPhaseStartTime(phaseOfRound1);
      endTime = getPhaseStartTime(phaseOfRound1 + 1);
      isTargetReached = targetReached(phaseOfRound1);
      chfCentsDonated = counter[phaseOfRound1];
    }
    tokenAmount = tokens[dfnAddr];
    donated = weiDonated[dfnAddr];
    fwdBalance = fwdAddr.balance;
  }
  function setWeiPerCHF(uint weis) {
    if (msg.sender != exchangeRateAuth) { throw; }
    weiPerCHF = weis;
  }
  function registerEarlyContrib(address addr, uint tokenAmount, bytes32 memo) {
    if (msg.sender != registrarAuth) { throw; }
    if (getState() != state.earlyContrib) { throw; }
    if (!isRegistered(addr, true)) {
      earlyContribList.push(addr);
    }
    assign(addr, tokenAmount, true);
    EarlyContribReceipt(addr, tokenAmount, memo);
  }
  function registerOffChainDonation(address addr, uint timestamp, uint chfCents, 
                                    string currency, bytes32 memo)
  {
    if (msg.sender != registrarAuth) { throw; }
    uint currentPhase = getPhaseAtTime(now);
    state currentState = stateOfPhase[currentPhase];
    if (currentState != state.round0 && currentState != state.round1 &&
        currentState != state.offChainReg) {
      throw;
    }
    if (timestamp > now) { throw; }
    uint timestampPhase = getPhaseAtTime(timestamp);
    state timestampState = stateOfPhase[timestampPhase];
    if ((currentState == state.round0 || currentState == state.round1) &&
        (timestampState != currentState)) { 
      throw;
    }
    if (currentState == state.offChainReg && timestampPhase != currentPhase-1) {
      throw;
    }
    if (memoUsed[memo]) {
      throw;
    }
    memoUsed[memo] = true;
    bookDonation(addr, timestamp, chfCents, currency, memo);
  }
  function delayDonPhase(uint donPhase, uint timedelta) {
    if (msg.sender != registrarAuth) { throw; }
    if (donPhase == 0) {
      delayPhaseEndBy(phaseOfRound0 - 1, timedelta);
    } else if (donPhase == 1) {
      delayPhaseEndBy(phaseOfRound1 - 1, timedelta);
    }
  }
  function setFoundationWallet(address newAddr) {
    if (msg.sender != masterAuth) { throw; }
    if (getPhaseAtTime(now) >= phaseOfRound0) { throw; }
    foundationWallet = newAddr;
  }
  function setExchangeRateAuth(address newAuth) {
    if (msg.sender != masterAuth) { throw; }
    exchangeRateAuth = newAuth;
  }
  function setRegistrarAuth(address newAuth) {
    if (msg.sender != masterAuth) { throw; }
    registrarAuth = newAuth;
  }
  function setMasterAuth(address newAuth) {
    if (msg.sender != masterAuth) { throw; }
    masterAuth = newAuth;
  }
  function donateAs(address addr) private returns (bool) {
    state st = getState();
    if (st != state.round0 && st != state.round1) { throw; }
    if (msg.value < minDonation) { throw; }
    if (weiPerCHF == 0) { throw; } 
    totalWeiDonated += msg.value;
    weiDonated[addr] += msg.value;
    uint chfCents = (msg.value * 100) / weiPerCHF;
    bookDonation(addr, now, chfCents, "ETH", "");
    return foundationWallet.call.value(this.balance)();
  }
  function bookDonation(address addr, uint timestamp, uint chfCents, 
                        string currency, bytes32 memo) private
  {
    uint phase = getPhaseAtTime(timestamp);
    bool targetReached = addTowardsTarget(phase, chfCents);
    if (targetReached && phase == getPhaseAtTime(now)) {
      if (phase == phaseOfRound0) {
        endCurrentPhaseIn(gracePeriodAfterRound0Target);
      } else if (phase == phaseOfRound1) {
        endCurrentPhaseIn(gracePeriodAfterRound1Target);
      }
    }
    uint bonusMultiplier = getMultiplierAtTime(timestamp);
    chfCents = (chfCents * bonusMultiplier) / 100;
    uint tokenAmount = (chfCents * tokensPerCHF) / 100;
    if (!isRegistered(addr, false)) {
      donorList.push(addr);
    }
    assign(addr,tokenAmount,false);
    DonationReceipt(addr, currency, bonusMultiplier, timestamp, tokenAmount, 
                    memo);
  }
}
