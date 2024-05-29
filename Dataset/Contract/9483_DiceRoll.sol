contract DiceRoll is SafeMath,usingOraclize {
    address public owner;
    uint8 constant public maxNumber = 99;
    uint8 constant public minNumber = 1;
    bool public gamePaused = false;
    bool public jackpotPaused = false;
    bool public refundPaused = false;
    uint256 public contractBalance;
    uint16 public houseEdge;
    uint256 public maxProfit;
    uint16 public maxProfitAsPercentOfHouse;
    uint256 public minBet;
    uint256 public maxBet;
    uint16 public jackpotOfHouseEdge;
    uint256 public minJackpotBet;
    uint256 public jackpotBlance;
    address[] public jackpotPlayer;
    uint256 public JackpotPeriods = 1;
    uint64 public nextJackpotTime;
    uint16 public jackpotPersent = 100;
    uint256 public totalWeiWon;
    uint256 public totalWeiWagered;
    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => uint256) playerBetAmount;
    mapping (bytes32 => uint8) playerNumberStart;
    mapping (bytes32 => uint8) playerNumberEnd;
    uint256 public oraclizeGasLimit;
    uint public oraclizeFee;
    uint seed;
    modifier betIsValid(uint256 _betSize, uint8 _start, uint8 _end) {
        require(_betSize >= minBet && _betSize <= maxBet && _start >= minNumber && _end <= maxNumber && _start < _end);
        _;
    }
    modifier oddEvenBetIsValid(uint256 _betSize, uint8 _oddeven) {
        require(_betSize >= minBet && _betSize <= maxBet && (_oddeven == 1 || _oddeven == 0));
        _;
    }
    modifier gameIsActive {
        require(!gamePaused);
        _;
    }
    modifier jackpotAreActive {
        require(!jackpotPaused);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyOraclize {
        require(msg.sender == oraclize_cbAddress());
        _;
    }
    event LogResult(bytes32 indexed QueryId, address indexed Address, uint8 DiceResult, uint256 Value, uint8 Status, uint8 Start, uint8 End, uint8 OddEven, uint256 BetValue);
    event LogRefund(bytes32 indexed QueryId, uint256 Amount);
    event LogJackpot(bytes32 indexed QueryId, address indexed Address, uint256 jackpotValue);
    event LogOwnerTransfer(address SentToAddress, uint256 AmountTransferred);
    event SendJackpotSuccesss(address indexed winner, uint256 amount, uint256 JackpotPeriods);
    function() public payable{
        contractBalance = safeAdd(contractBalance, msg.value);
        setMaxProfit();
    }
    function DiceRoll() public {
        owner = msg.sender;
        houseEdge = 20;  
        maxProfitAsPercentOfHouse = 100;  
        minBet = 0.1 ether;
        maxBet = 1 ether;
        jackpotOfHouseEdge = 500;  
        minJackpotBet = 0.1 ether;
        jackpotPersent = 100;  
        oraclizeGasLimit = 300000;
        oraclizeFee = 1200000000000000; 
        oraclize_setCustomGasPrice(4000000000);
        nextJackpotTime = uint64(block.timestamp);
        oraclize_setProof(proofType_Ledger);
    }
    function playerRoll(uint8 start, uint8 end) public payable gameIsActive betIsValid(msg.value, start, end) {
        totalWeiWagered += msg.value;
        bytes32 queryId = oraclize_newRandomDSQuery(0, 30, oraclizeGasLimit);
        playerAddress[queryId] = msg.sender;
        playerBetAmount[queryId] = msg.value;
        playerNumberStart[queryId] = start;
        playerNumberEnd[queryId] = end;
        contractBalance = safeSub(contractBalance,oraclizeFee);
    }
    function oddEven(uint8 oddeven) public payable gameIsActive oddEvenBetIsValid(msg.value, oddeven) {
        totalWeiWagered += msg.value;
        bytes32 queryId = oraclize_newRandomDSQuery(0, 30, oraclizeGasLimit);
        playerAddress[queryId] = msg.sender;
        playerBetAmount[queryId] = msg.value;
        playerNumberStart[queryId] = oddeven;
        playerNumberEnd[queryId] = 0;
        contractBalance = safeSub(contractBalance,oraclizeFee);
    }
    function __callback(bytes32 queryId, string result, bytes proof) public onlyOraclize {
        if (oraclize_randomDS_proofVerify__returnCode(queryId, result, proof) != 0) {
            if(!refundPaused){
                playerAddress[queryId].transfer(playerBetAmount[queryId]);
                LogRefund(queryId, playerBetAmount[queryId]);
            }else{
                contractBalance = safeAdd(contractBalance,playerBetAmount[queryId]);
            }
        }else{
            uint8 tempStart = playerNumberStart[queryId];
            uint8 tempEnd = playerNumberEnd[queryId];
            address tempAddress = playerAddress[queryId];
            uint256 tempAmount = playerBetAmount[queryId];
            uint8 probability;
            uint256 houseEdgeFee;
            uint256 playerProfit;
            uint8 random = uint8(uint256(keccak256(result)) % 100) + 1;
            delete playerAddress[queryId];
            delete playerBetAmount[queryId];
            delete playerNumberStart[queryId];
            delete playerNumberEnd[queryId];
            if(tempEnd == 0){
                if(random % 2 == tempStart){
                    probability = 50;
                    playerProfit = getProfit(probability,tempAmount);
                    totalWeiWon = safeAdd(totalWeiWon, playerProfit);
                    contractBalance = safeSub(contractBalance, playerProfit);
                    setMaxProfit();
                    LogResult(queryId, tempAddress, random, playerProfit, 1, 0, 0, tempStart, tempAmount);
                    houseEdgeFee = getHouseEdgeFee(probability, tempAmount);
                    increaseJackpot(houseEdgeFee * jackpotOfHouseEdge / 1000, queryId, tempAddress, tempAmount);
                    tempAddress.transfer(safeAdd(playerProfit, tempAmount));  
                }else{
                    LogResult(queryId, tempAddress, random, 0, 0, 0, 0, tempEnd, tempAmount); 
                    contractBalance = safeAdd(contractBalance, (tempAmount - 1));
                    setMaxProfit();
                    tempAddress.transfer(1);
                }
            }else if(tempEnd != 0 && tempStart != 0){
                if(tempStart <= random && random <= tempEnd){
                    probability = tempEnd - tempStart + 1;
                    playerProfit = getProfit(probability,tempAmount);
                    totalWeiWon = safeAdd(totalWeiWon, playerProfit);
                    contractBalance = safeSub(contractBalance, playerProfit);
                    setMaxProfit();
                    LogResult(queryId, tempAddress, random, playerProfit, 1, tempStart, tempEnd, 2, tempAmount);
                    houseEdgeFee = getHouseEdgeFee(probability, tempAmount);
                    increaseJackpot(houseEdgeFee * jackpotOfHouseEdge / 1000, queryId, tempAddress, tempAmount);
                    tempAddress.transfer(safeAdd(playerProfit, tempAmount));   
                }else{
                    LogResult(queryId, tempAddress, random, 0, 0, tempStart, tempEnd, 2, tempAmount); 
                    contractBalance = safeAdd(contractBalance, (tempAmount - 1));
                    setMaxProfit();
                    tempAddress.transfer(1);
                }
            }
        }
    }
    function increaseJackpot(uint256 increaseAmount, bytes32 _queryId, address _address, uint256 _amount) internal {
        require(increaseAmount < maxProfit);
        LogJackpot(_queryId, _address, increaseAmount);
        contractBalance = safeSub(contractBalance, increaseAmount);
        jackpotBlance = safeAdd(jackpotBlance, increaseAmount);
        if(_amount >= minJackpotBet){
            jackpotPlayer.push(_address);
        }
    }
    function createWinner() public onlyOwner jackpotAreActive {
        uint64 tmNow = uint64(block.timestamp);
        require(tmNow >= nextJackpotTime);
        require(jackpotPlayer.length > 0);
        uint random = rand() % jackpotPlayer.length;
        address winner = jackpotPlayer[random - 1];
        sendJackpot(winner);
    }
    function sendJackpot(address winner) internal jackpotAreActive {
        uint256 amount = jackpotBlance * jackpotPersent / 1000;
        require(jackpotBlance > amount);
        jackpotBlance = safeSub(jackpotBlance, amount);
        jackpotPlayer.length = 0;
        nextJackpotTime = uint64(block.timestamp) + 72000;
        winner.transfer(amount);
        SendJackpotSuccesss(winner, amount, JackpotPeriods);
        JackpotPeriods += 1;
    }
    function sendValueToJackpot() payable public jackpotAreActive {
        jackpotBlance = safeAdd(jackpotBlance, msg.value);
    }
    function getHouseEdgeFee(uint8 _probability, uint256 _betValue) view internal returns (uint256){
        return (_betValue * (100 - _probability) / _probability + _betValue) * houseEdge / 1000;
    }
    function getProfit(uint8 _probability, uint256 _betValue) view internal returns (uint256){
        uint256 tempProfit = ((_betValue * (100 - _probability) / _probability + _betValue) * (1000 - houseEdge) / 1000) - _betValue;
        if(tempProfit > maxProfit) tempProfit = maxProfit;
        return tempProfit;
    }
    function rand() internal returns (uint256) {
        seed = uint256(keccak256(seed, block.blockhash(block.number - 1), block.coinbase, block.difficulty));
        return seed;
    }
    function setMaxProfit() internal {
        maxProfit = contractBalance * maxProfitAsPercentOfHouse / 1000;  
    }
    function ownerSetOraclizeGas(uint newPrice, uint newGasLimit) public onlyOwner{
        require(newGasLimit > 50000 && newGasLimit <300000);
        require(newPrice > 1000000000 && newPrice <15000000000); 
        oraclize_setCustomGasPrice(newPrice);
        oraclizeGasLimit = newGasLimit;
        oraclizeFee = newGasLimit * newPrice; 
    }
    function ownerSetHouseEdge(uint16 newHouseEdge) public onlyOwner{
        require(newHouseEdge <= 1000);
        houseEdge = newHouseEdge;
    }
    function ownerSetMinJackpoBet(uint256 newVal) public onlyOwner{
        require(newVal <= 1 ether);
        minJackpotBet = newVal;
    }
    function ownerSetMaxProfitAsPercentOfHouse(uint8 newMaxProfitAsPercent) public onlyOwner{
        require(newMaxProfitAsPercent <= 1000);
        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
        setMaxProfit();
    }
    function ownerSetMinBet(uint256 newMinimumBet) public onlyOwner{
        minBet = newMinimumBet;
    }
    function ownerSetMaxBet(uint256 newMaxBet) public onlyOwner{
        maxBet = newMaxBet;
    }
    function ownerSetJackpotOfHouseEdge(uint16 newProportion) public onlyOwner{
        require(newProportion < 1000);
        jackpotOfHouseEdge = newProportion;
    }
    function ownerPauseGame(bool newStatus) public onlyOwner{
        gamePaused = newStatus;
    }
    function ownerPauseJackpot(bool newStatus) public onlyOwner{
        jackpotPaused = newStatus;
    }
    function ownerTransferEther(address sendTo, uint256 amount) public onlyOwner{	
        contractBalance = safeSub(contractBalance, amount);
        sendTo.transfer(amount);
        setMaxProfit();
        LogOwnerTransfer(sendTo, amount);
    }
    function ownerChangeOwner(address newOwner) public onlyOwner{
        owner = newOwner;
    }
    function ownerkill() public onlyOwner{
        selfdestruct(owner);
    }
}
