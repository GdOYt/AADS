contract usingInvestorsModule is HouseManaged, oraclizeSettings {
    uint constant MAX_INVESTORS = 5;  
    uint constant divestFee = 50;  
     struct Investor {
        address investorAddress;
        uint amountInvested;
        bool votedForEmergencyWithdrawal;
    }
    mapping(address => uint) public investorIDs;
    mapping(uint => Investor) public investors;
    uint public numInvestors = 0;
    uint public invested = 0;
    uint public investorsProfit = 0;
    uint public investorsLosses = 0;
    bool profitDistributed;
    event LOG_InvestorEntrance(address indexed investor, uint amount);
    event LOG_InvestorCapitalUpdate(address indexed investor, int amount);
    event LOG_InvestorExit(address indexed investor, uint amount);
    event LOG_EmergencyAutoStop();
    event LOG_ZeroSend();
    event LOG_ValueIsTooBig();
    event LOG_FailedSend(address addr, uint value);
    event LOG_SuccessfulSend(address addr, uint value);
    modifier onlyMoreThanMinInvestment {
        assert(msg.value > getMinInvestment());
        _;
    }
    modifier onlyMoreThanZero {
        assert(msg.value != 0);
        _;
    }
    modifier onlyInvestors {
        assert(investorIDs[msg.sender] != 0);
        _;
    }
    modifier onlyNotInvestors {
        assert(investorIDs[msg.sender] == 0);
        _;
    }
    modifier investorsInvariant {
        _;
        assert(numInvestors <= MAX_INVESTORS);
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
        if (numInvestors == MAX_INVESTORS) {
            uint investorID = searchSmallestInvestor();
            return getBalance(investors[investorID].investorAddress);
        }
        else {
            return 0;
        }
    }
    function getLossesShare(address currentInvestor)
        constant
        returns (uint) {
        return (investors[investorIDs[currentInvestor]].amountInvested * investorsLosses) / invested;
    }
    function getProfitShare(address currentInvestor)
        constant
        returns (uint) {
        return (investors[investorIDs[currentInvestor]].amountInvested * investorsProfit) / invested;
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
    function addInvestorAtID(uint id)
        private {
        investorIDs[msg.sender] = id;
        investors[id].investorAddress = msg.sender;
        investors[id].amountInvested = msg.value;
        invested += msg.value;
        LOG_InvestorEntrance(msg.sender, msg.value);
    }
    function profitDistribution()
        private {
        if (profitDistributed) return;
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
            copyInvested += investors[i].amountInvested; 
        }
        delete investorsProfit;
        delete investorsLosses;
        invested = copyInvested;
        profitDistributed = true;
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
        if (numInvestors == MAX_INVESTORS) {
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
        internal
        investorsInvariant {
        profitDistribution();
        uint currentID = investorIDs[currentInvestor];
        uint amountToReturn = getBalance(currentInvestor);
        if (invested >= investors[currentID].amountInvested) {
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
    function safeSend(address addr, uint value)
        internal {
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
}
