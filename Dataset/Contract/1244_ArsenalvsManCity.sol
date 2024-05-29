contract ArsenalvsManCity is usingOraclize {
  address public OWNERS = 0xC3eD2d481B9d75835EC04174b019A7eAF2Faf78A;
  uint public constant COMMISSION = 0;  
  uint public constant MIN_BET = 0.01 ether;
  uint public EXPECTED_START = 1534086000;  
  uint public EXPECTED_END = 1534096800;  
  uint public constant BETTING_OPENS = 1533851317;
  uint public BETTING_CLOSES = EXPECTED_START - 60;  
  uint public constant PING_ORACLE_INTERVAL = 60 * 60 * 24;  
  uint public ORACLIZE_GAS = 200000;
  uint public CANCELATION_DATE = EXPECTED_END + 60 * 60 * 24;  
  uint public RETURN_DATE = EXPECTED_END + 60 * 60 * 24 * 30;  
  bool public completed;
  bool public canceled;
  bool public ownersPayed;
  uint public ownerPayout;
  bool public returnedToOwners;
  uint public winnerDeterminedDate;
  uint public numCollected = 0;
  bytes32 public nextScheduledQuery;
  uint public oraclizeFees;
  uint public collectionFees;
  struct Better {
    uint betAmount;
    uint betOption;
    bool withdrawn;
  }
  mapping(address => Better) betterInfo;
  address[] public betters;
  uint[2] public totalAmountsBet;
  uint[2] public numberOfBets;
  uint public totalBetAmount;
  uint public winningOption = 2;
  event BetMade();
  modifier canDetermineWinner() {
    require (winningOption == 2 && !completed && !canceled && now > BETTING_CLOSES && now >= EXPECTED_END);
    _;
  }
  modifier canEmptyRemainings() {
    require(canceled || completed);
    uint numRequiredToCollect = canceled ? (numberOfBets[0] + numberOfBets[1]) : numberOfBets[winningOption];
    require ((now >= RETURN_DATE && !canceled) || (numCollected == numRequiredToCollect));
    _;
  }
  modifier collectionsEnabled() {
    require (canceled || (winningOption != 2 && completed && now > BETTING_CLOSES));
    _;
  }
  modifier canPayOwners() {
    require (!canceled && winningOption != 2 && completed && !ownersPayed && now > BETTING_CLOSES);
    _;
  }
  modifier bettingIsClosed() {
    require (now >= BETTING_CLOSES);
    _;
  }
  modifier onlyOwnerLevel() {
    require(
      OWNERS == msg.sender
    );
    _;
  }
  function ArsenalvsManCity() public payable {
    oraclize_setCustomGasPrice(1000000000);
    callOracle(EXPECTED_END, ORACLIZE_GAS);  
  }
  function changeGasLimitAndPrice(uint gas, uint price) public onlyOwnerLevel {
    ORACLIZE_GAS = gas;
    oraclize_setCustomGasPrice(price);
  }
  function setExpectedTimes(uint _EXPECTED_START, uint _EXPECTED_END) public onlyOwnerLevel {
    setExpectedStart(_EXPECTED_START);
    setExpectedEnd(_EXPECTED_END);
  }
  function setExpectedStart(uint _EXPECTED_START) public onlyOwnerLevel {
    EXPECTED_START = _EXPECTED_START;
    BETTING_CLOSES = EXPECTED_START - 60;
  }
  function setExpectedEnd(uint _EXPECTED_END) payable public onlyOwnerLevel {
    require(_EXPECTED_END > EXPECTED_START);
    EXPECTED_END = _EXPECTED_END;
    CANCELATION_DATE = EXPECTED_END + 60 * 60 * 24;
    RETURN_DATE = EXPECTED_END + 60 * 60 * 24 * 30;
    callOracle(EXPECTED_END, ORACLIZE_GAS);  
  }
  function callOracle(uint timeOrDelay, uint gas) private {
    require(canceled != true && completed != true);
    nextScheduledQuery = makeOraclizeQuery(timeOrDelay, "nested", "[computation] ['QmRQAbvyJacfnNVyf4f3SWs1kjKdJf36eaXRvEwA8Wzq6i', '233027', '${[decrypt] BM/Sk9ifIw/U3W7+wt+ZN45oFLQSuPNY8SXs9LG3MbvbD5+J2pdPkbpGJzcL4GTmZ+Gti1Rnqviolxc8LZluklWPBwKUP8jsOGtthw3fxNDwtwxpNuj8xplBo5n1uvK7ItzGZ8aAB+vb0drf5XcN3vk=}']", gas);
  }
  function makeOraclizeQuery(uint timeOrDelay, string datasource, string query, uint gas) private returns(bytes32) {
    oraclizeFees += oraclize_getPrice(datasource, gas);
    return oraclize_query(timeOrDelay, datasource, query, gas);
  }
  function determineWinner(uint gas, uint gasPrice) payable public onlyOwnerLevel canDetermineWinner {
    ORACLIZE_GAS = gas;
    oraclize_setCustomGasPrice(gasPrice);
    callOracle(0, ORACLIZE_GAS);
  }
  function __callback(bytes32 queryId, string result, bytes proof) public canDetermineWinner {
    require(msg.sender == oraclize_cbAddress());
    if (keccak256(result) != keccak256("0") && keccak256(result) != keccak256("1")) {
      if (now >= CANCELATION_DATE) {
        cancel();
      }
      else if (nextScheduledQuery == queryId) {
        callOracle(PING_ORACLE_INTERVAL, ORACLIZE_GAS);
      }
    }
    else {
      setWinner(parseInt(result));
    }
  }
  function setWinner(uint winner) private {
    completed = true;
    canceled = false;
    winningOption = winner;
    winnerDeterminedDate = now;
    payOwners();
  }
  function getUserBet(address addr) public constant returns(uint[]) {
    uint[] memory bets = new uint[](2);
    bets[betterInfo[addr].betOption] = betterInfo[addr].betAmount;
    return bets;
  }
  function userHasWithdrawn(address addr) public constant returns(bool) {
    return betterInfo[addr].withdrawn;
  }
  function collectionsAvailable() public constant returns(bool) {
    return (completed && winningOption != 2 && now >= (winnerDeterminedDate + 600));  
  }
  function canBet() public constant returns(bool) {
    return (now >= BETTING_OPENS && now < BETTING_CLOSES && !canceled && !completed);
  }
  function bet(uint option) public payable {
    require(canBet() == true);
    require(msg.value >= MIN_BET);
    require(betterInfo[msg.sender].betAmount == 0 || betterInfo[msg.sender].betOption == option);
    if (betterInfo[msg.sender].betAmount == 0) {
      betterInfo[msg.sender].betOption = option;
      numberOfBets[option]++;
      betters.push(msg.sender);
    }
    betterInfo[msg.sender].betAmount += msg.value;
    totalBetAmount += msg.value;
    totalAmountsBet[option] += msg.value;
    BetMade();  
  }
  function emptyRemainingsToOwners() private canEmptyRemainings {
    OWNERS.transfer(this.balance);
    returnedToOwners = true;
  }
  function returnToOwners() public onlyOwnerLevel canEmptyRemainings {
    emptyRemainingsToOwners();
  }
  function payOwners() private canPayOwners {
    if (COMMISSION == 0) {
      ownersPayed = true;
      ownerPayout = 0;
      if (numberOfBets[winningOption] > 0) {
        collectionFees = ((oraclizeFees != 0) ? (oraclizeFees / numberOfBets[winningOption] + 1) : 0);  
      }
      return;
    }
    uint losingChunk = totalAmountsBet[1 - winningOption];
    ownerPayout = (losingChunk - oraclizeFees) / COMMISSION;  
    if (numberOfBets[winningOption] > 0) {
      collectionFees = ((oraclizeFees != 0) ? ((oraclizeFees - oraclizeFees / COMMISSION) / numberOfBets[winningOption] + 1) : 0);  
    }
    OWNERS.transfer(ownerPayout);
    ownersPayed = true;
  }
  function cancelBet() payable public onlyOwnerLevel {
    cancel();
  }
  function cancel() private {
    canceled = true;
    completed = false;
  }
  function() payable public {
  }
  function collect() public collectionsEnabled {
    address better = msg.sender;
    require(betterInfo[better].betAmount > 0);
    require(!betterInfo[better].withdrawn);
    require(canceled != completed);
    require(canceled || (completed && betterInfo[better].betOption == winningOption));
    require(now >= (winnerDeterminedDate + 600));
    uint payout = 0;
    if (!canceled) {
      uint losingChunk = totalAmountsBet[1 - winningOption];
      payout = betterInfo[better].betAmount + (betterInfo[better].betAmount * (losingChunk - ownerPayout) / totalAmountsBet[winningOption]) - collectionFees;
    }
    else {
      payout = betterInfo[better].betAmount;
    }
    if (payout > 0) {
      better.transfer(payout);
      betterInfo[better].withdrawn = true;
      numCollected++;
    }
  }
}
