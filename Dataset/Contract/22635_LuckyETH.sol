contract LuckyETH is usingOraclize, DSSafeAddSub {
     using strings for *;
    modifier betIsValid(uint _betSize, uint _playerNumber) {      
        if(_betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) throw;        
        _;
    }
    modifier gameIsActive {
        if(gamePaused == true) throw;
        _;
    }    
    modifier payoutsAreActive {
        if(payoutsPaused == true) throw;
        _;
    }    
    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }
    modifier onlyOwner {
         if (msg.sender != owner) throw;
         _;
    }
    modifier onlyTreasury {
         if (msg.sender != treasury) throw;
         _;
    }    
    uint constant public maxNumber = 999; 
    uint constant public minNumber = 2;
    bool public gamePaused;
    uint32 public gasForOraclize;
    address public owner;
    bool public payoutsPaused; 
    address public treasury;
    uint public minBet; 
    uint public maxPendingPayouts;
    string queryUrl = "http://randseed.org/api/randintwithseed?min=1&apikey=wSxw2ssJdSdfD3320S&seed=";
    string cryptoFrom = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    string cryptoTo =   "E8HdOBYKcRCD0UT45s1rLQjXIfWZAqS9xlM2ntFNvapb6uiJoyzVPG7hkmeg3w";
    bool isCaissaSet;
    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => address) playerTempAddress;
    mapping (bytes32 => bytes32) playerBetId;
    mapping (bytes32 => uint) playerBetValue;
    mapping (bytes32 => uint) playerTempBetValue;
    mapping (bytes32 => uint) playerRandomResult;            
    mapping (bytes32 => uint) playerDieResult;
    mapping (bytes32 => uint) playerNumber;
    mapping (address => uint) playerPendingWithdrawals;      
    mapping (bytes32 => uint) playerProfit;
    mapping (bytes32 => uint) playerTempReward;  
    mapping (bytes32 => address) playerFromAddr;
    mapping (bytes1 => bytes1) caissa;         
    function LuckyETH() {
        owner = msg.sender;
        treasury = msg.sender;
        oraclize_setNetwork(networkID_auto);        
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        ownerSetMinBet(100000000000000000);        
        gasForOraclize = 255000;  
        oraclize_setCustomGasPrice(20000000000 wei);  
        isCaissaSet = false;           
    }
    function toAsciiString(address x) internal returns (string) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
    function char(byte b) internal returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    function setCaissa() public onlyOwner {
        bytes memory cfrom = bytes(cryptoFrom);
        bytes memory cto = bytes(cryptoTo);
        for (uint i = 0; i < cfrom.length; i++) {
            caissa[cfrom[i]] = cto[i];
        }
        isCaissaSet = true;
    }
    function encrypt(string _v) public view returns (string) {
        require(isCaissaSet == true);
        bytes memory v= bytes(_v);
        uint len = v.length; 
        for (uint i = 0; i < len; i++) {
            if (caissa[v[i]] != 0) {
                v[i] = caissa[v[i]];
            }
        }
        return string(v);
    }
    function playerRollDiceSingle(uint rollTimes) public 
        payable
        gameIsActive
        betIsValid(msg.value, rollTimes)
    {       
        string memory pre1 = strConcat(queryUrl, encrypt(toAsciiString(msg.sender)), "_", encrypt(uint2str(msg.value)), "&max=");
        bytes32 rngId = oraclize_query(
            "URL",
            strConcat(pre1, uint2str(rollTimes), "&format=pure"),
            gasForOraclize
        );
        playerFromAddr[rngId] = address(0);
        playerBetId[rngId] = rngId;
        playerNumber[rngId] = rollTimes;
        playerBetValue[rngId] = msg.value;
        playerAddress[rngId] = msg.sender;
        playerProfit[rngId] = msg.value * rollTimes;        
        maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
    }   
    function playerRollDice(uint rollTimes, address fromAddr) public 
        payable
        gameIsActive
        betIsValid(msg.value, rollTimes)
    {       
        string memory pre1 = strConcat(queryUrl, encrypt(toAsciiString(msg.sender)), "_", encrypt(uint2str(msg.value)), "&max=");
        bytes32 rngId = oraclize_query(
            "URL",
            strConcat(pre1, uint2str(rollTimes), "&format=pure"),
            gasForOraclize
        );
        playerFromAddr[rngId] = fromAddr;
        playerBetId[rngId] = rngId;
        playerNumber[rngId] = rollTimes;
        playerBetValue[rngId] = msg.value;
        playerAddress[rngId] = msg.sender;
        playerProfit[rngId] = msg.value * rollTimes;        
        maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
    }   
    function __callback(bytes32 myid, string result, bytes proof) public   
        onlyOraclize
        payoutsAreActive
    {  
        if (playerAddress[myid]==0x0) throw;
        bool refundFlag = false;
        if (bytes(result).length > 10) {
            refundFlag = true;
        } else {
            playerRandomResult[myid] = parseInt(result);            
        }
        playerDieResult[myid] = playerRandomResult[myid];    
        playerTempAddress[myid] = playerAddress[myid];
        delete playerAddress[myid];
        playerTempReward[myid] = playerProfit[myid];
        playerProfit[myid] = 0; 
        maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);         
        playerTempBetValue[myid] = playerBetValue[myid];
        playerBetValue[myid] = 0; 
        if(playerDieResult[myid] == 0 || playerRandomResult[myid] == 0|| refundFlag == true)
        {                                                     
            if(!playerTempAddress[myid].send(playerTempBetValue[myid]))
            {           
                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);                        
            }
            return;
        }
        if(playerDieResult[myid] == 1)
        { 
            uint cutValue1 = playerTempReward[myid] / 100;
            playerTempReward[myid] = safeSub(playerTempReward[myid], cutValue1);
            if(!playerTempAddress[myid].send(playerTempReward[myid]))
            {                 
                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);                               
            }
            if(playerFromAddr[myid] == address(0)) return;
            if(!playerFromAddr[myid].send(playerTempBetValue[myid] * 5 / 1000))
            {
                playerPendingWithdrawals[playerFromAddr[myid]] = safeAdd(playerPendingWithdrawals[playerFromAddr[myid]], playerTempBetValue[myid] * 5 / 1000);
            }
            return;
        }
        if(playerDieResult[myid] != 1){
            uint cutValue2 = playerTempBetValue[myid] * 5 / 1000;
            if(!playerTempAddress[myid].send(1)){
               playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);                                
            }   
            if(playerFromAddr[myid] == address(0)) return;
            if(!playerFromAddr[myid].send(cutValue2)) {
               playerPendingWithdrawals[playerFromAddr[myid]] = safeAdd(playerPendingWithdrawals[playerFromAddr[myid]], cutValue2);                                
            }
            return;
        }
    }
    function playerWithdrawPendingTransactions() public 
        payoutsAreActive
        returns (bool)
     {
        uint withdrawAmount = playerPendingWithdrawals[msg.sender];
        playerPendingWithdrawals[msg.sender] = 0;
        if (msg.sender.call.value(withdrawAmount)()) {
            return true;
        } else {
            playerPendingWithdrawals[msg.sender] = withdrawAmount;
            return false;
        }
    }
    function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
        return playerPendingWithdrawals[addressToCheck];
    } 
    function ()
        payable
        onlyTreasury
    {
    } 
    function ownerSetCallbackGasPrice(uint newCallbackGasPrice) public 
        onlyOwner
    {
        oraclize_setCustomGasPrice(newCallbackGasPrice);
    }     
    function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
        onlyOwner
    {
        gasForOraclize = newSafeGasToOraclize;
    }
    function ownerSetMinBet(uint newMinimumBet) public 
        onlyOwner
    {
        minBet = newMinimumBet;
    }       
    function ownerTransferEther(address sendTo, uint amount) public 
        onlyOwner
    {        
        if(!sendTo.send(amount)) throw;
    }
    function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
        onlyOwner
    {        
        maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);
        if(!sendTo.send(originalPlayerBetValue)) throw;      
    }    
    function ownerPauseGame(bool newStatus) public 
        onlyOwner
    {
        gamePaused = newStatus;
    }
    function ownerPausePayouts(bool newPayoutStatus) public 
        onlyOwner
    {
        payoutsPaused = newPayoutStatus;
    } 
    function ownerSetTreasury(address newTreasury) public 
        onlyOwner
    {
        treasury = newTreasury;
    }         
    function ownerChangeOwner(address newOwner) public 
        onlyOwner
    {
        owner = newOwner;
    }
    function ownerkill() public 
        onlyOwner
    {
        suicide(owner);
    }    
}
