contract BananaGame is usingOraclize{
    uint constant times = 16;
    uint safeGas = 2300;
    uint ORACLIZE_GAS_LIMIT = 130000;
    uint percent = 95; 
    uint minBet =2 finney;
    address public owner;
    bool public isStopped;
    uint public maxInvestors = 10; 
    uint public divestFee = 50; 
    address public houseAddress;
    mapping (bytes32 => Bet) public bets; 
    bytes32[] public betsKeys;
    uint public investorsNum = 0; 
    mapping(address => uint) public investorIDs; 
    mapping(uint => Investor) public investors; 
    uint public investorsProfit = 0;
    uint public investorsLosses = 0;
    bool profitDistributed;
    uint public invest;
    event LOG_OwnerAddressChanged(address owner,address newOwner);
    event LOG_NewBet(address addr, uint value);
    event LOG_ContractStopped();
    event LOG_GasLimitChanged(uint oldGasLimit, uint newGasLimit);
    event LOG_FailedSend(address receiver, uint amount); 
    event LOG_ZeroSend();
    event LOG_ValueIsTooBig();
    event LOG_SuccessfulSend(address receiver,uint amountBet,uint profit);
    event LOG_CurrentPercent(uint percent); 
    event LOG_SuccessfulDraw(address addr,uint value);
    event LOG_FailedDraw(address addr,uint value);
    event LOG_InvestorCapitalUpdate(address investor, int amount); 
    event LOG_EmergencyAutoStop();
    event LOG_InvestorEntrance(address investor, uint amount,uint ways);
    event LOG_MaxInvestorsChanged(uint value);
    struct Bet{
        address playerAddr;
        uint amountBet;
        bytes betResult;
    }
    struct Investor {
        address investorAddress;
        uint amountInvested;
        uint originInvested;
    }
    modifier onlyOwner{
        if(msg.sender!=owner) throw;
        _;
    }
    modifier onlyOraclize{
        if(msg.sender !=oraclize_cbAddress()) throw;
        _;
    }
    modifier onlyIfNotStopped{
        if(isStopped) throw;
        _;
    }
    modifier onlyIfValidGas(uint newGasLimit) {
        if (ORACLIZE_GAS_LIMIT + newGasLimit < ORACLIZE_GAS_LIMIT) throw;
        if (newGasLimit < 1000) throw;
        _;
    }
    modifier checkBetValue(uint value){
        if(value<getMinBetAmount() ||value>getMaxBetAmount()) throw;
        _;
    }
    modifier onlyIfBetExist(bytes32 myid) {
        if(bets[myid].playerAddr == address(0x0)) throw;
        _;
    }
    modifier onlyIfNotProcessed(bytes32 myid) {
        if (bets[myid].betResult.length >=times) throw;
        _;
    }
    modifier onlyIfProfitNotDistributed {
        if (!profitDistributed) {
            _;
        }
    }
    modifier onlyInvestors {
        if (investorIDs[msg.sender] == 0) throw;
        _;
    }
    modifier onlyMoreThanZero {
        if (msg.value == 0) throw;
        _;
    }
    modifier validInvestNum(uint n){
        if(n>investorsNum) throw;
        _;
    }
    function BananaGame(){
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        owner = msg.sender;
        houseAddress = msg.sender;
     }
    function () payable{
        bet();
    }
    function bet() payable onlyIfNotStopped checkBetValue(msg.value){
            uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
            if (oraclizeFee >= msg.value) throw;
            uint betValue = msg.value - oraclizeFee;
            LOG_NewBet(msg.sender,betValue);
            bytes32 myid =
                oraclize_query(
                        "nested",
                        "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random.data', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BKIKtXqteUWKc5NZV65n1ioNrhWdKsJ2+AK4wkjlUWSympyWgJ0HuO106V/duAf3YGBp/lPr9+wN489QCUgbyyqE7SIG2wxa/DnKwF+z9hr3GGYLM1R64AibTHg12RTzSP/d+kOJKkOo54mCJ1XIuVAm5yT71Rk=},\"n\":16,\"min\":0,\"max\":1${[identity] \"}\"},\"id\":1${[identity] \"}\"}']",
                        ORACLIZE_GAS_LIMIT + safeGas
                );
            bets[myid] = Bet(msg.sender, betValue, "");
            betsKeys.push(myid);
    }
    function __callback(bytes32 myid, string result, bytes proof) onlyOraclize onlyIfBetExist(myid) 
    onlyIfNotProcessed(myid) {
        bytes memory queue = bytes(result);
        string memory sd_s =new string(times);
        bytes memory sd = bytes(sd_s); 
        uint k=0;
        if(queue.length<times){
            return;
        }
        Bet user = bets[myid]; 
        uint initAccount=user.amountBet; 
        initAccount = initAccount*percent/100; 
        uint getAccount;
        bool computeOrNot=true;
        for(uint i=0 ;i<queue.length;i++){
            if(queue[i]==48){
                sd[k] =queue[i];
                if(computeOrNot){
                    computeOrNot=false;
                }
                k++;
                if(k>times-1){
                    break;
                }
            }else if(queue[i]==49){
                if(computeOrNot){
                    if(getAccount+initAccount<getAccount||initAccount+getAccount<initAccount){
                        throw;
                    }
                    getAccount +=initAccount;
                    initAccount = initAccount*percent/100; 
                }
                sd[k] =queue[i];
                k++;
                if(k>times-1){
                    break;
                }
            }
        }
        if(getAccount!=0){
            safeSend(user.playerAddr,user.amountBet,getAccount);
        }else{
            safeSend(user.playerAddr,user.amountBet,1);
        }
        user.betResult = sd;
        delete profitDistributed;
    }
    function safeSend(address addr,uint amount,uint value) internal{
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
        }
        if((int)(value-amount)>0){
            investorsLosses +=value-amount;
        }else{
            investorsProfit +=amount-value;
        }
        LOG_SuccessfulSend(addr,amount,value);
    }
    function safeSend(address addr,uint value) internal{
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
        }
    }
    function setStopped() onlyOwner{
        isStopped =true;
        LOG_ContractStopped();
    }
    function setStarted() onlyOwner{
        isStopped =false;
    }
    function getBetNum() constant returns (uint){
        return betsKeys.length;
    }
    function getBet(uint id) constant returns(address,uint,string){
        if (id < betsKeys.length) {
            bytes32 betKey = betsKeys[id];
            return (bets[betKey].playerAddr, bets[betKey].amountBet, (string)(bets[betKey].betResult));
        }
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
    function changePercent(uint _percent) onlyOwner{
        if(_percent<0 || _percent>100) throw;
        percent = _percent;
    }
    function watchPercent() constant returns (uint){
        return percent;
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
    function getMinBetAmount()
        constant
        returns(uint) {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        return  minBet+oraclizeFee;
    }
    function getMaxBetAmount() constant returns (uint){
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        return oraclizeFee+getBankroll()*(100-percent)/100;
    }
    function getPlayerBetResult(uint i) constant returns (string){
        if(i>=0 && i< betsKeys.length){
            bytes32 id =betsKeys[i];
            Bet player = bets[id];
            return string(player.betResult);
        }else{
            throw;
        }
    }
    function getLossesShare(address currentInvestor)
        constant
        returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsLosses) / invest;
    }
    function getProfitShare(address currentInvestor)
        constant
        returns (uint) {
        return investors[investorIDs[currentInvestor]].amountInvested * (investorsProfit) / invest;
    }
    function getBalance(address currentInvestor) constant returns(uint){
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
    function profitDistribution()
        internal
        onlyIfProfitNotDistributed {
        uint copyInvested;
        for (uint i = 1; i <= investorsNum; i++) {
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
        invest = copyInvested;
        profitDistributed = true;
    }
    function divest()
        onlyInvestors {
        divest(msg.sender);
    }
    function divest(address currentInvestor)
        internal{
        profitDistribution();
        uint currentID = investorIDs[currentInvestor];
        uint amountToReturn = getBalance(currentInvestor);
        if ((invest >= investors[currentID].amountInvested)) {
            invest -= investors[currentID].amountInvested;
            uint divestFeeAmount =  (amountToReturn*divestFee)/10000;
            amountToReturn -= divestFeeAmount;
            delete investors[currentID];
            delete investorIDs[currentInvestor];
            if (currentID != investorsNum) {
                Investor lastInvestor = investors[investorsNum];
                investorIDs[lastInvestor.investorAddress] = currentID;
                investors[currentID] = lastInvestor;
                delete investors[investorsNum];
            }
            investorsNum--;
            safeSend(currentInvestor, amountToReturn);
            safeSend(houseAddress, divestFeeAmount);
            LOG_InvestorEntrance(msg.sender, amountToReturn,3);
        } else {
            isStopped = true;
            LOG_EmergencyAutoStop();
        } 
    }
    function addInvest() payable onlyIfNotStopped onlyMoreThanZero{
        if(investorIDs[msg.sender]>0){
            profitDistribution();
            investors[investorIDs[msg.sender]].amountInvested += msg.value;
            investors[investorIDs[msg.sender]].originInvested += msg.value;
            invest += msg.value;
            LOG_InvestorEntrance(msg.sender, msg.value,2);
        }else{
            if(msg.value>getMinInvestment()){
                profitDistribution();
                if(investorsNum==maxInvestors){
                    uint minId = searchSmallestInvestor();
                    divest(investors[minId].investorAddress);
                }
                investorsNum++;
                addInvestorAtID(investorsNum);
            }else{
                throw;
            }
        }
    }
    function addInvestorAtID(uint id)
        internal {
        investorIDs[msg.sender] = id;
        investors[id].investorAddress = msg.sender;
        investors[id].amountInvested = msg.value;
        investors[id].originInvested = msg.value;
        invest += msg.value;
        LOG_InvestorEntrance(msg.sender, msg.value,1);
    }
    function getMinInvestment()
        constant
        returns(uint) {
        if (investorsNum == maxInvestors) {
            uint investorID = searchSmallestInvestor();
            return getBalance(investors[investorID].investorAddress);
        }
        else {
            return 0;
        }
    }
    function searchSmallestInvestor()
        constant
        returns(uint) {
        uint investorID = investorsNum;
        for (uint i = investorsNum; i >=1 ; i--) {
            if (getBalance(investors[i].investorAddress) < getBalance(investors[investorID].investorAddress)) {
                investorID = i;
            }
        }
        return investorID;
    }
    function forceDivestOfAllInvestors()
        onlyOwner {
        uint copyNumInvestors = investorsNum;
        for (uint i = 1; i <= copyNumInvestors; i++) {
            divest(investors[1].investorAddress);
        }
    }
    function changeInvestNum(uint num) onlyOwner{
        if(num <= investorsNum ) throw;
        maxInvestors = num;
        LOG_MaxInvestorsChanged(num);
    }
    function changeDivestFee(uint value) onlyOwner{
        if(value<0 || value>10000){
            divestFee = value;
        }
    }
    function getBankroll()
        constant
        returns(uint) {
        if ((invest < investorsProfit) ||
            (invest + investorsProfit < invest) ||
            (invest + investorsProfit < investorsLosses)) {
            return 0;
        }
        else {
            return invest + investorsProfit - investorsLosses;
        }
    }
    function getStatus() constant returns(uint,uint,uint,uint){
        uint bankroll = getBankroll();
        uint minBet = getMinBetAmount();
        uint maxBet = getMaxBetAmount();
        return (bankroll,minBet,maxBet,investorsNum);
    }
    function getInvestStatus(uint n) validInvestNum(n) constant returns(address,uint,uint ) {
        address addr = investors[n].investorAddress;
        uint originInvested = investors[n].originInvested;
        uint currentCaptial = getBalance(addr)*(10000-divestFee)/10000;
        return (addr,originInvested,currentCaptial);
    }
    function changeMinBet(uint value) onlyOwner{
         if(value<0 || value >getBankroll()*(100-percent)/100) throw;
         minBet = value;
    }
    function changeORACLIZE_GAS_LIMIT(uint value) onlyOwner{
        ORACLIZE_GAS_LIMIT =value;
    }
    function getOraFee() constant returns (uint){
        return OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas); 
    }
    function getBetKey(uint i) constant returns  (bytes32){
        return betsKeys[i];
    }
    function changeHouseAddress(address addr) onlyOwner{
        if (addr == address(0x0)) throw;
        houseAddress = addr;
    }
    function destroy() onlyOwner{
        forceDivestOfAllInvestors();
        suicide(owner);
    }
}
