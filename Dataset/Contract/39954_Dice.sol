contract Dice is usingOraclize {
    uint constant pwin = 7500;  
    uint constant edge = 190;  
    uint constant maxWin = 100;  
    uint constant minBet = 200 finney;
    uint constant maxInvestors = 10;  
    uint constant houseEdge = 25;  
    uint constant divestFee = 50;  
    uint constant emergencyWithdrawalRatio = 10;  
    uint safeGas = 2300;
    uint constant ORACLIZE_GAS_LIMIT = 175000;
    uint constant INVALID_BET_MARKER = 99999;
    uint constant EMERGENCY_TIMEOUT = 3 days;
    struct Investor {
        address investorAddress;
        uint amountInvested;
        bool votedForEmergencyWithdrawal;
    }
    struct Bet {
        address playerAddress;
        uint amountBet;
        uint numberRolled;
    }
    struct WithdrawalProposal {
        address toAddress;
        uint atTime;
    }
    mapping(address => uint) public investorIDs;
    mapping(uint => Investor) public investors;
    uint public numInvestors = 0;
    uint public invested = 0;
    address public owner;
    address public houseAddress;
    bool public isStopped;
    WithdrawalProposal public proposedWithdrawal;
    mapping (bytes32 => Bet) public bets;
    bytes32[] public betsKeys;
    uint public investorsProfit = 0;
    uint public investorsLosses = 0;
    bool profitDistributed;
    event LOG_NewBet(address playerAddress, uint amount);
    event LOG_BetWon(address playerAddress, uint numberRolled, uint amountWon);
    event LOG_BetLost(address playerAddress, uint numberRolled);
    event LOG_EmergencyWithdrawalProposed();
    event LOG_EmergencyWithdrawalFailed(address withdrawalAddress);
    event LOG_EmergencyWithdrawalSucceeded(address withdrawalAddress, uint amountWithdrawn);
    event LOG_FailedSend(address receiver, uint amount);
    event LOG_ZeroSend();
    event LOG_InvestorEntrance(address investor, uint amount);
    event LOG_InvestorCapitalUpdate(address investor, int amount);
    event LOG_InvestorExit(address investor, uint amount);
    event LOG_ContractStopped();
    event LOG_ContractResumed();
    event LOG_OwnerAddressChanged(address oldAddr, address newOwnerAddress);
    event LOG_HouseAddressChanged(address oldAddr, address newHouseAddress);
    event LOG_GasLimitChanged(uint oldGasLimit, uint newGasLimit);
    event LOG_EmergencyAutoStop();
    event LOG_EmergencyWithdrawalVote(address investor, bool vote);
    event LOG_ValueIsTooBig();
    event LOG_SuccessfulSend(address addr, uint amount);
    function Dice() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        owner = msg.sender;
        houseAddress = msg.sender;
    }
    modifier onlyIfNotStopped {
        if (isStopped) throw;
        _;
    }
    modifier onlyIfStopped {
        if (!isStopped) throw;
        _;
    }
    modifier onlyInvestors {
        if (investorIDs[msg.sender] == 0) throw;
        _;
    }
    modifier onlyNotInvestors {
        if (investorIDs[msg.sender] != 0) throw;
        _;
    }
    modifier onlyOwner {
        if (owner != msg.sender) throw;
        _;
    }
    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }
    modifier onlyMoreThanMinInvestment {
        if (msg.value <= getMinInvestment()) throw;
        _;
    }
    modifier onlyMoreThanZero {
        if (msg.value == 0) throw;
        _;
    }
    modifier onlyIfBetExist(bytes32 myid) {
        if(bets[myid].playerAddress == address(0x0)) throw;
        _;
    }
    modifier onlyIfBetSizeIsStillCorrect(bytes32 myid) {
        if ((((bets[myid].amountBet * ((10000 - edge) - pwin)) / pwin ) <= (maxWin * getBankroll()) / 10000)  && (bets[myid].amountBet >= minBet)) {
             _;
        }
        else {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(bets[myid].playerAddress, bets[myid].amountBet);
            return;
        }
    }
    modifier onlyIfValidRoll(bytes32 myid, string result) {
        uint numberRolled = parseInt(result);
        if ((numberRolled < 1 || numberRolled > 10000) && bets[myid].numberRolled == 0) {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(bets[myid].playerAddress, bets[myid].amountBet);
            return;
        }
        _;
    }
    modifier onlyWinningBets(uint numberRolled) {
        if (numberRolled - 1 < pwin) {
            _;
        }
    }
    modifier onlyLosingBets(uint numberRolled) {
        if (numberRolled - 1 >= pwin) {
            _;
        }
    }
    modifier onlyAfterProposed {
        if (proposedWithdrawal.toAddress == 0) throw;
        _;
    }
    modifier onlyIfProfitNotDistributed {
        if (!profitDistributed) {
            _;
        }
    }
    modifier onlyIfValidGas(uint newGasLimit) {
        if (ORACLIZE_GAS_LIMIT + newGasLimit < ORACLIZE_GAS_LIMIT) throw;
        if (newGasLimit < 25000) throw;
        _;
    }
    modifier onlyIfNotProcessed(bytes32 myid) {
        if (bets[myid].numberRolled > 0) throw;
        _;
    }
    modifier onlyIfEmergencyTimeOutHasPassed {
        if (proposedWithdrawal.atTime + EMERGENCY_TIMEOUT > now) throw;
        _;
    }
    modifier investorsInvariant {
        _;
        if (numInvestors > maxInvestors) throw;
    }
    function getBankroll()
        constant
        returns(uint) {
        if ((invested < investorsProfit) ||
            (invested + investorsProfit < invested) ||
            (invested + investorsProfit < investorsLosses)) {
            return 0;
        }
        else {
            return invested + investorsProfit - investorsLosses;
        }
    }
    function getMinInvestment()
        constant
        returns(uint) {
        if (numInvestors == maxInvestors) {
            uint investorID = searchSmallestInvestor();
            return getBalance(investors[investorID].investorAddress);
        }
        else {
            return 0;
        }
    }
    function getStatus()
        constant
        returns(uint, uint, uint, uint, uint, uint, uint, uint) {
        uint bankroll = getBankroll();
        uint minInvestment = getMinInvestment();
        return (bankroll, pwin, edge, maxWin, minBet, (investorsProfit - investorsLosses), minInvestment, betsKeys.length);
    }
    function getBet(uint id)
        constant
        returns(address, uint, uint) {
        if (id < betsKeys.length) {
            bytes32 betKey = betsKeys[id];
            return (bets[betKey].playerAddress, bets[betKey].amountBet, bets[betKey].numberRolled);
        }
    }
    function numBets()
        constant
        returns(uint) {
        return betsKeys.length;
    }
    function getMinBetAmount()
        constant
        returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        return oraclizeFee + minBet;
    }
    function getMaxBetAmount()
        constant
        returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint betValue =  (maxWin * getBankroll()) * pwin / (10000 * (10000 - edge - pwin));
        return betValue + oraclizeFee;
    }
    function getLossesShare(address currentInvestor)
        constant
        returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsLosses) / invested;
    }
    function getProfitShare(address currentInvestor)
        constant
        returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsProfit) / invested;
    }
    function getBalance(address currentInvestor)
        constant
        returns (uint) {
        uint invested = investors[investorIDs[currentInvestor]].amountInvested;
        uint profit = getProfitShare(currentInvestor);
        uint losses = getLossesShare(currentInvestor);
        if ((invested + profit < profit) ||
            (invested + profit < invested) ||
            (invested + profit < losses))
            return 0;
        else
            return invested + profit - losses;
    }
    function searchSmallestInvestor()
        constant
        returns(uint) {
        uint investorID = 1;
        for (uint i = 1; i <= numInvestors; i++) {
            if (getBalance(investors[i].investorAddress) < getBalance(investors[investorID].investorAddress)) {
                investorID = i;
            }
        }
        return investorID;
    }
    function changeOraclizeProofType(byte _proofType)
        onlyOwner {
        if (_proofType == 0x00) throw;
        oraclize_setProof( _proofType |  proofStorage_IPFS );
    }
    function changeOraclizeConfig(bytes32 _config)
        onlyOwner {
        oraclize_setConfig(_config);
    }
    function safeSend(address addr, uint value)
        private {
        if (value == 0) {
            LOG_ZeroSend();
            return;
        }
        if (this.balance < value) {
            LOG_ValueIsTooBig();
            return;
        }
        if (!(addr.call.gas(safeGas).value(value)())) {
            LOG_FailedSend(addr, value);
            if (addr != houseAddress) {
                if (!(houseAddress.call.gas(safeGas).value(value)())) LOG_FailedSend(houseAddress, value);
            }
        }
        LOG_SuccessfulSend(addr,value);
    }
    function addInvestorAtID(uint id)
        private {
        investorIDs[msg.sender] = id;
        investors[id].investorAddress = msg.sender;
        investors[id].amountInvested = msg.value;
        invested += msg.value;
        LOG_InvestorEntrance(msg.sender, msg.value);
    }
    function profitDistribution()
        private
        onlyIfProfitNotDistributed {
        uint copyInvested;
        for (uint i = 1; i <= numInvestors; i++) {
            address currentInvestor = investors[i].investorAddress;
            uint profitOfInvestor = getProfitShare(currentInvestor);
            uint lossesOfInvestor = getLossesShare(currentInvestor);
            if ((investors[i].amountInvested + profitOfInvestor >= investors[i].amountInvested) &&
                (investors[i].amountInvested + profitOfInvestor >= lossesOfInvestor))  {
                investors[i].amountInvested += profitOfInvestor - lossesOfInvestor;
                LOG_InvestorCapitalUpdate(currentInvestor, (int) (profitOfInvestor - lossesOfInvestor));
            }
            else {
                isStopped = true;
                LOG_EmergencyAutoStop();
            }
            if (copyInvested + investors[i].amountInvested >= copyInvested)
                copyInvested += investors[i].amountInvested;
        }
        delete investorsProfit;
        delete investorsLosses;
        invested = copyInvested;
        profitDistributed = true;
    }
    function()
        payable {
        bet();
    }
    function bet()
        payable
        onlyIfNotStopped {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        if (oraclizeFee >= msg.value) throw;
        uint betValue = msg.value - oraclizeFee;
        if ((((betValue * ((10000 - edge) - pwin)) / pwin ) <= (maxWin * getBankroll()) / 10000) && (betValue >= minBet)) {
            LOG_NewBet(msg.sender, betValue);
            bytes32 myid =
                oraclize_query(
                    "nested",
                    "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random.data.0', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BD/A+lI7OwcDJW+y4Qo1cDia95LO/jW5x1X12pluCsF5Z/U9GbhKxVk3OPEjWBskxHy980dPa5y9y0XVg6TknHK9z+bK9gckTQUPP7LUonPlxdhHnyhq1t1uop06yXzkIn6rER/huIwvrk0rt6eVW3RBqSDpK3o=},\"n\":1,\"min\":1,\"max\":10000${[identity] \"}\"},\"id\":1${[identity] \"}\"}']",
                    ORACLIZE_GAS_LIMIT + safeGas
                );
            bets[myid] = Bet(msg.sender, betValue, 0);
            betsKeys.push(myid);
        }
        else {
            throw;
        }
    }
    function __callback(bytes32 myid, string result, bytes proof)
        onlyOraclize
        onlyIfBetExist(myid)
        onlyIfNotProcessed(myid)
        onlyIfValidRoll(myid, result)
        onlyIfBetSizeIsStillCorrect(myid)  {
        uint numberRolled = parseInt(result);
        bets[myid].numberRolled = numberRolled;
        isWinningBet(bets[myid], numberRolled);
        isLosingBet(bets[myid], numberRolled);
        delete profitDistributed;
    }
    function isWinningBet(Bet thisBet, uint numberRolled)
        private
        onlyWinningBets(numberRolled) {
        uint winAmount = (thisBet.amountBet * (10000 - edge)) / pwin;
        LOG_BetWon(thisBet.playerAddress, numberRolled, winAmount);
        safeSend(thisBet.playerAddress, winAmount);
        if ((investorsLosses + winAmount < investorsLosses) ||
            (investorsLosses + winAmount < thisBet.amountBet)) {
                throw;
            }
        investorsLosses += winAmount - thisBet.amountBet;
    }
    function isLosingBet(Bet thisBet, uint numberRolled)
        private
        onlyLosingBets(numberRolled) {
        LOG_BetLost(thisBet.playerAddress, numberRolled);
        safeSend(thisBet.playerAddress, 1);
        if ((investorsProfit + thisBet.amountBet < investorsProfit) ||
            (investorsProfit + thisBet.amountBet < thisBet.amountBet) ||
            (thisBet.amountBet == 1)) {
                throw;
            }
        uint totalProfit = investorsProfit + (thisBet.amountBet - 1);  
        investorsProfit += (thisBet.amountBet - 1)*(10000 - houseEdge)/10000;
        uint houseProfit = totalProfit - investorsProfit;  
        safeSend(houseAddress, houseProfit);
    }
    function increaseInvestment()
        payable
        onlyIfNotStopped
        onlyMoreThanZero
        onlyInvestors  {
        profitDistribution();
        investors[investorIDs[msg.sender]].amountInvested += msg.value;
        invested += msg.value;
    }
    function newInvestor()
        payable
        onlyIfNotStopped
        onlyMoreThanZero
        onlyNotInvestors
        onlyMoreThanMinInvestment
        investorsInvariant {
        profitDistribution();
        if (numInvestors == maxInvestors) {
            uint smallestInvestorID = searchSmallestInvestor();
            divest(investors[smallestInvestorID].investorAddress);
        }
        numInvestors++;
        addInvestorAtID(numInvestors);
    }
    function divest()
        onlyInvestors {
        divest(msg.sender);
    }
    function divest(address currentInvestor)
        private
        investorsInvariant {
        profitDistribution();
        uint currentID = investorIDs[currentInvestor];
        uint amountToReturn = getBalance(currentInvestor);
        if ((invested >= investors[currentID].amountInvested)) {
            invested -= investors[currentID].amountInvested;
            uint divestFeeAmount =  (amountToReturn*divestFee)/10000;
            amountToReturn -= divestFeeAmount;
            delete investors[currentID];
            delete investorIDs[currentInvestor];
            if (currentID != numInvestors) {
                Investor lastInvestor = investors[numInvestors];
                investorIDs[lastInvestor.investorAddress] = currentID;
                investors[currentID] = lastInvestor;
                delete investors[numInvestors];
            }
            numInvestors--;
            safeSend(currentInvestor, amountToReturn);
            safeSend(houseAddress, divestFeeAmount);
            LOG_InvestorExit(currentInvestor, amountToReturn);
        } else {
            isStopped = true;
            LOG_EmergencyAutoStop();
        }
    }
    function forceDivestOfAllInvestors()
        onlyOwner {
        uint copyNumInvestors = numInvestors;
        for (uint i = 1; i <= copyNumInvestors; i++) {
            divest(investors[1].investorAddress);
        }
    }
    function forceDivestOfOneInvestor(address currentInvestor)
        onlyOwner
        onlyIfStopped {
        divest(currentInvestor);
        delete proposedWithdrawal;
    }
    function stopContract()
        onlyOwner {
        isStopped = true;
        LOG_ContractStopped();
    }
    function resumeContract()
        onlyOwner {
        isStopped = false;
        LOG_ContractResumed();
    }
    function changeHouseAddress(address newHouse)
        onlyOwner {
        if (newHouse == address(0x0)) throw;  
        houseAddress = newHouse;
        LOG_HouseAddressChanged(houseAddress, newHouse);
    }
    function changeOwnerAddress(address newOwner)
        onlyOwner {
        if (newOwner == address(0x0)) throw;
        owner = newOwner;
        LOG_OwnerAddressChanged(owner, newOwner);
    }
    function changeGasLimitOfSafeSend(uint newGasLimit)
        onlyOwner
        onlyIfValidGas(newGasLimit) {
        safeGas = newGasLimit;
        LOG_GasLimitChanged(safeGas, newGasLimit);
    }
    function voteEmergencyWithdrawal(bool vote)
        onlyInvestors
        onlyAfterProposed
        onlyIfStopped {
        investors[investorIDs[msg.sender]].votedForEmergencyWithdrawal = vote;
        LOG_EmergencyWithdrawalVote(msg.sender, vote);
    }
    function proposeEmergencyWithdrawal(address withdrawalAddress)
        onlyIfStopped
        onlyOwner {
        for (uint i = 1; i <= numInvestors; i++) {
            delete investors[i].votedForEmergencyWithdrawal;
        }
        proposedWithdrawal = WithdrawalProposal(withdrawalAddress, now);
        LOG_EmergencyWithdrawalProposed();
    }
    function executeEmergencyWithdrawal()
        onlyOwner
        onlyAfterProposed
        onlyIfStopped
        onlyIfEmergencyTimeOutHasPassed {
        uint numOfVotesInFavour;
        uint amountToWithdraw = this.balance;
        for (uint i = 1; i <= numInvestors; i++) {
            if (investors[i].votedForEmergencyWithdrawal == true) {
                numOfVotesInFavour++;
                delete investors[i].votedForEmergencyWithdrawal;
            }
        }
        if (numOfVotesInFavour >= emergencyWithdrawalRatio * numInvestors / 100) {
            if (!proposedWithdrawal.toAddress.send(amountToWithdraw)) {
                LOG_EmergencyWithdrawalFailed(proposedWithdrawal.toAddress);
            }
            else {
                LOG_EmergencyWithdrawalSucceeded(proposedWithdrawal.toAddress, amountToWithdraw);
            }
        }
        else {
            throw;
        }
    }
}
