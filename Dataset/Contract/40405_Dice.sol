contract Dice is usingOraclize {
    uint public pwin = 5000;  
    uint public edge = 200;  
    uint public maxWin = 100;  
    uint public minBet = 1 finney;
    uint public maxInvestors = 5;  
    uint public houseEdge = 50;  
    uint public divestFee = 50;  
    uint public emergencyWithdrawalRatio = 90;  
    uint safeGas = 25000;
    uint constant ORACLIZE_GAS_LIMIT = 125000;
    uint constant INVALID_BET_MARKER = 99999;
    uint constant EMERGENCY_TIMEOUT = 7 days;
    struct Investor {
        address investorAddress;
        uint amountInvested;
        bool votedForEmergencyWithdrawal;
    }
    struct Bet {
        address playerAddress;
        uint amountBetted;
        uint numberRolled;
    }
    struct WithdrawalProposal {
        address toAddress;
        uint atTime;
    }
    mapping(address => uint) investorIDs;
    mapping(uint => Investor) investors;
    uint public numInvestors = 0;
    uint public invested = 0;
    address owner;
    address houseAddress;
    bool public isStopped;
    WithdrawalProposal proposedWithdrawal;
    mapping (bytes32 => Bet) bets;
    bytes32[] betsKeys;
    uint public amountWagered = 0;
    uint public investorsProfit = 0;
    uint public investorsLoses = 0;
    bool profitDistributed;
    event BetWon(address playerAddress, uint numberRolled, uint amountWon);
    event BetLost(address playerAddress, uint numberRolled);
    event EmergencyWithdrawalProposed();
    event EmergencyWithdrawalFailed(address withdrawalAddress);
    event EmergencyWithdrawalSucceeded(address withdrawalAddress, uint amountWithdrawn);
    event FailedSend(address receiver, uint amount);
    event ValueIsTooBig();
    function Dice(uint pwinInitial,
                  uint edgeInitial,
                  uint maxWinInitial,
                  uint minBetInitial,
                  uint maxInvestorsInitial,
                  uint houseEdgeInitial,
                  uint divestFeeInitial,
                  uint emergencyWithdrawalRatioInitial
                  ) {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        pwin = pwinInitial;
        edge = edgeInitial;
        maxWin = maxWinInitial;
        minBet = minBetInitial;
        maxInvestors = maxInvestorsInitial;
        houseEdge = houseEdgeInitial;
        divestFee = divestFeeInitial;
        emergencyWithdrawalRatio = emergencyWithdrawalRatioInitial;
        owner = msg.sender;
        houseAddress = msg.sender;
    }
    modifier onlyIfNotStopped {
        if (isStopped) throw;
        _
    }
    modifier onlyIfStopped {
        if (!isStopped) throw;
        _
    }
    modifier onlyInvestors {
        if (investorIDs[msg.sender] == 0) throw;
        _
    }
    modifier onlyNotInvestors {
        if (investorIDs[msg.sender] != 0) throw;
        _
    }
    modifier onlyOwner {
        if (owner != msg.sender) throw;
        _
    }
    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _
    }
    modifier onlyMoreThanMinInvestment {
        if (msg.value <= getMinInvestment()) throw;
        _
    }
    modifier onlyMoreThanZero {
        if (msg.value == 0) throw;
        _
    }
    modifier onlyIfBetSizeIsStillCorrect(bytes32 myid) {
        Bet thisBet = bets[myid];
        if ((((thisBet.amountBetted * ((10000 - edge) - pwin)) / pwin ) <= (maxWin * getBankroll()) / 10000)) {
             _
        }
        else {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(thisBet.playerAddress, thisBet.amountBetted);
            return;
        }
    }
    modifier onlyIfValidRoll(bytes32 myid, string result) {
        Bet thisBet = bets[myid];
        uint numberRolled = parseInt(result);
        if ((numberRolled < 1 || numberRolled > 10000) && thisBet.numberRolled == 0) {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(thisBet.playerAddress, thisBet.amountBetted);
            return;
        }
        _
    }
    modifier onlyIfInvestorBalanceIsPositive(address currentInvestor) {
        if (getBalance(currentInvestor) >= 0) {
            _
        }
    }
    modifier onlyWinningBets(uint numberRolled) {
        if (numberRolled - 1 < pwin) {
            _
        }
    }
    modifier onlyLosingBets(uint numberRolled) {
        if (numberRolled - 1 >= pwin) {
            _
        }
    }
    modifier onlyAfterProposed {
        if (proposedWithdrawal.toAddress == 0) throw;
        _
    }
    modifier rejectValue {
        if (msg.value != 0) throw;
        _
    }
    modifier onlyIfProfitNotDistributed {
        if (!profitDistributed) {
            _
        }
    }
    modifier onlyIfValidGas(uint newGasLimit) {
        if (newGasLimit < 25000) throw;
        _
    }
    modifier onlyIfNotProcessed(bytes32 myid) {
        Bet thisBet = bets[myid];
        if (thisBet.numberRolled > 0) throw;
        _
    }
    modifier onlyIfEmergencyTimeOutHasPassed {
        if (proposedWithdrawal.atTime + EMERGENCY_TIMEOUT > now) throw;
        _
    }
    function getBankroll() constant returns(uint) {
        return invested + investorsProfit - investorsLoses;
    }
    function getMinInvestment() constant returns(uint) {
        if (numInvestors == maxInvestors) {
            uint investorID = searchSmallestInvestor();
            return getBalance(investors[investorID].investorAddress);
        }
        else {
            return 0;
        }
    }
    function getStatus() constant returns(uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        uint bankroll = getBankroll();
        if (this.balance < bankroll) {
            bankroll = this.balance;
        }
        uint minInvestment = getMinInvestment();
        return (bankroll, pwin, edge, maxWin, minBet, amountWagered, (investorsProfit - investorsLoses), minInvestment, betsKeys.length);
    }
    function getBet(uint id) constant returns(address, uint, uint) {
        if (id < betsKeys.length) {
            bytes32 betKey = betsKeys[id];
            return (bets[betKey].playerAddress, bets[betKey].amountBetted, bets[betKey].numberRolled);
        }
    }
    function numBets() constant returns(uint) {
        return betsKeys.length;
    }
    function getMinBetAmount() constant returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        return oraclizeFee + minBet;
    }
    function getMaxBetAmount() constant returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint betValue =  (maxWin * getBankroll()) * pwin / (10000 * (10000 - edge - pwin));
        return betValue + oraclizeFee;
    }
    function getLosesShare(address currentInvestor) constant returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsLoses) / invested;
    }
    function getProfitShare(address currentInvestor) constant returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsProfit) / invested;
    }
    function getBalance(address currentInvestor) constant returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested + getProfitShare(currentInvestor) - getLosesShare(currentInvestor);
    }
    function searchSmallestInvestor() private returns(uint) {
        uint investorID = 1;
        for (uint i = 1; i <= numInvestors; i++) {
            if (getBalance(investors[i].investorAddress) < getBalance(investors[investorID].investorAddress)) {
                investorID = i;
            }
        }
        return investorID;
    }
    function safeSend(address addr, uint value) private {
        if (this.balance < value) {
            ValueIsTooBig();
            return;
        }
        if (!(addr.call.gas(safeGas).value(value)())) {
            FailedSend(addr, value);
            if (addr != houseAddress) {
                if (!(houseAddress.call.gas(safeGas).value(value)())) FailedSend(houseAddress, value);
            }
        }
    }
    function addInvestorAtID(uint id) private {
        investorIDs[msg.sender] = id;
        investors[id].investorAddress = msg.sender;
        investors[id].amountInvested = msg.value;
        invested += msg.value;
    }
    function profitDistribution() private onlyIfProfitNotDistributed {
        uint copyInvested;
        for (uint i = 1; i <= numInvestors; i++) {
            address currentInvestor = investors[i].investorAddress;
            uint profitOfInvestor = getProfitShare(currentInvestor);
            uint losesOfInvestor = getLosesShare(currentInvestor);
            investors[i].amountInvested += profitOfInvestor - losesOfInvestor;
            copyInvested += investors[i].amountInvested;
        }
        delete investorsProfit;
        delete investorsLoses;
        invested = copyInvested;
        profitDistributed = true;
    }
    function() {
        bet();
    }
    function bet() onlyIfNotStopped onlyMoreThanZero {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint betValue = msg.value - oraclizeFee;
        if ((((betValue * ((10000 - edge) - pwin)) / pwin ) <= (maxWin * getBankroll()) / 10000) && (betValue >= minBet)) {
            bytes32 myid = oraclize_query("URL", "json(https://api.random.org/json-rpc/1/invoke).result.random.data.0", 'BCPnjiU1UySjNV2Nj003k7TFMVA/ddeUVwDlNnvte/GMShwVuchXA3Ul4vl3U656g7ZMq+H5Upk42wujF4p6gbasCoh7vTMlOXdG3Ehct+buCpx99Y8FSqyoAItrPtSTKZ1BHDnl5UF0oPv4tcG+L9ahH0cD8J6U/5I8OJBvjitE103Fxqo2W90bGIhnBeunSlQoHzN+zMIMmzNQJvp/PtybJSKfmfxiaqC+vCt4CywRLxI8pGijdhbwSzncjwg/wrYHFrJmcugmEPOvx7Entmnpec1MssnR1weOhayIzBU=', ORACLIZE_GAS_LIMIT + safeGas);
            bets[myid] = Bet(msg.sender, betValue, 0);
            betsKeys.push(myid);
        }
        else {
            throw;
        }
    }
    function __callback (bytes32 myid, string result, bytes proof)
        onlyOraclize
        onlyIfNotProcessed(myid)
        onlyIfValidRoll(myid, result)
        onlyIfBetSizeIsStillCorrect(myid)  {
        Bet thisBet = bets[myid];
        uint numberRolled = parseInt(result);
        bets[myid].numberRolled = numberRolled;
        isWinningBet(thisBet, numberRolled);
        isLosingBet(thisBet, numberRolled);
        amountWagered += thisBet.amountBetted;
        delete profitDistributed;
    }
    function isWinningBet(Bet thisBet, uint numberRolled) private onlyWinningBets(numberRolled) {
        uint winAmount = (thisBet.amountBetted * (10000 - edge)) / pwin;
        BetWon(thisBet.playerAddress, numberRolled, winAmount);
        safeSend(thisBet.playerAddress, winAmount);
        investorsLoses += (winAmount - thisBet.amountBetted);
    }
    function isLosingBet(Bet thisBet, uint numberRolled) private onlyLosingBets(numberRolled) {
        BetLost(thisBet.playerAddress, numberRolled);
        safeSend(thisBet.playerAddress, 1);
        investorsProfit += (thisBet.amountBetted - 1)*(10000 - houseEdge)/10000;
        uint houseProfit = (thisBet.amountBetted - 1)*(houseEdge)/10000;
        safeSend(houseAddress, houseProfit);
    }
    function increaseInvestment() onlyIfNotStopped onlyMoreThanZero onlyInvestors  {
        profitDistribution();
        investors[investorIDs[msg.sender]].amountInvested += msg.value;
        invested += msg.value;
    }
    function newInvestor()
        onlyIfNotStopped
        onlyMoreThanZero
        onlyNotInvestors
        onlyMoreThanMinInvestment {
        profitDistribution();
        if (numInvestors < maxInvestors) {
            numInvestors++;
            addInvestorAtID(numInvestors);
        }
        else {
            uint smallestInvestorID = searchSmallestInvestor();
            divest(investors[smallestInvestorID].investorAddress);
            addInvestorAtID(smallestInvestorID);
            numInvestors++;
        }
    }
    function divest() onlyInvestors rejectValue {
        divest(msg.sender);
    }
    function divest(address currentInvestor)
        private
        onlyIfInvestorBalanceIsPositive(currentInvestor) {
        profitDistribution();
        uint currentID = investorIDs[currentInvestor];
        uint amountToReturn = getBalance(currentInvestor);
        invested -= investors[currentID].amountInvested;
        uint divestFeeAmount =  (amountToReturn*divestFee)/10000;
        amountToReturn -= divestFeeAmount;
        numInvestors--;
        delete investors[currentID];
        delete investorIDs[currentInvestor];
        safeSend(currentInvestor, amountToReturn);
        safeSend(houseAddress, divestFeeAmount);
    }
    function forceDivestOfAllInvestors() onlyOwner rejectValue {
        uint copyNumInvestors = numInvestors;
        for (uint investorID = 1; investorID <= copyNumInvestors; investorID++) {
            divest(investors[investorID].investorAddress);
        }
    }
    function forceDivestOfOneInvestor(address currentInvestor)
        onlyOwner
        onlyIfStopped
        rejectValue {
        divest(currentInvestor);
        delete proposedWithdrawal;
    }
    function stopContract() onlyOwner rejectValue {
        isStopped = true;
    }
    function resumeContract() onlyOwner rejectValue {
        isStopped = false;
    }
    function changeHouseAddress(address newHouse) onlyOwner rejectValue {
        houseAddress = newHouse;
    }
    function changeOwnerAddress(address newOwner) onlyOwner rejectValue {
        owner = newOwner;
    }
    function changeGasLimitOfSafeSend(uint newGasLimit)
        onlyOwner
        onlyIfValidGas(newGasLimit)
        rejectValue {
        safeGas = newGasLimit;
    }
    function voteEmergencyWithdrawal(bool vote)
        onlyInvestors
        onlyAfterProposed
        onlyIfStopped
        rejectValue {
        investors[investorIDs[msg.sender]].votedForEmergencyWithdrawal = vote;
    }
    function proposeEmergencyWithdrawal(address withdrawalAddress)
        onlyIfStopped
        onlyOwner
        rejectValue {
        for (uint i = 1; i <= numInvestors; i++) {
            delete investors[i].votedForEmergencyWithdrawal;
        }
        proposedWithdrawal = WithdrawalProposal(withdrawalAddress, now);
        EmergencyWithdrawalProposed();
    }
    function executeEmergencyWithdrawal()
        onlyOwner
        onlyAfterProposed
        onlyIfStopped
        onlyIfEmergencyTimeOutHasPassed
        rejectValue {
        uint numOfVotesInFavour;
        uint amountToWithdrawal = this.balance;
        for (uint i = 1; i <= numInvestors; i++) {
            if (investors[i].votedForEmergencyWithdrawal == true) {
                numOfVotesInFavour++;
                delete investors[i].votedForEmergencyWithdrawal;
            }
        }
        if (numOfVotesInFavour >= emergencyWithdrawalRatio * numInvestors / 100) {
            if (!proposedWithdrawal.toAddress.send(this.balance)) {
                EmergencyWithdrawalFailed(proposedWithdrawal.toAddress);
            }
            else {
                EmergencyWithdrawalSucceeded(proposedWithdrawal.toAddress, amountToWithdrawal);
            }
        }
        else {
            throw;
        }
    }
}
