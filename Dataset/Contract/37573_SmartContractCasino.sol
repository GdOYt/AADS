contract SmartContractCasino is usingOraclize, DSSafeAddSub {
using strings for *;
modifier betIsValid(uint _betSize, uint _playerNumber) {
if (((((_betSize * (100- (safeSub(_playerNumber, 1)))) / (safeSub(_playerNumber, 1))+ _betSize)) * houseEdge / houseEdgeDivisor) -_betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) require(false);
_;
}
modifier gameIsActive {
require(gamePaused != true);
_;
}
modifier payoutsAreActive {
require(payoutsPaused != true);
_;
}
modifier onlyOraclize {
require(msg.sender == oraclize_cbAddress());
_;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyTreasury {
require(msg.sender == treasury);
_;
}
uint constant public maxProfitDivisor = 1000000;
uint constant public houseEdgeDivisor = 1000;
uint constant public maxNumber = 99;
uint constant public minNumber = 2;
bool public gamePaused;
uint32 public gasForOraclize;
address public owner;
bool public payoutsPaused;
address public treasury;
uint public contractBalance;
uint public houseEdge;
uint public maxProfit;
uint public maxProfitAsPercentOfHouse;
uint public minBet;
int public totalBets = 751;
uint public maxPendingPayouts;
uint public totalWeiWon = 67308420060000000000;
uint public totalWeiWagered = 115849260000000000000;
mapping (bytes32 => address) playerAddress;
mapping (bytes32 => address) playerTempAddress;
mapping (bytes32 => bytes32) playerBetId;
mapping (bytes32 => uint) playerBetValue;
mapping (bytes32 => uint) playerTempBetValue;
mapping (bytes32 => uint) playerDieResult;
mapping (bytes32 => uint) playerNumber;
mapping (address => uint) playerPendingWithdrawals;
mapping (bytes32 => uint) playerProfit;
mapping (bytes32 => uint) playerTempReward;
event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);
event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, uint BetValue, uint PlayerNumber, uint DiceResult, uint Value, int Status, bytes Proof);
event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);
function SmartContractCasino() {
owner = msg.sender;
treasury = msg.sender;
oraclize_setNetwork(networkID_auto);
oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
ownerSetHouseEdge(990);
ownerSetMaxProfitAsPercentOfHouse(100000);
ownerSetMinBet(100000000000000000);
gasForOraclize = 250000;
}
function playerRollDice(uint rollUnder) public
payable
gameIsActive
betIsValid(msg.value, rollUnder)
{
contractBalance = safeSub(contractBalance, oraclize_getPrice("URL", gasForOraclize));
totalBets += 1;
totalWeiWagered += msg.value;
bytes32 rngId = oraclize_query("nested", "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10,\"apiKey\":${[decrypt] BCH6hHWdskd8vb1IyJufVawsvBSsXN34RTD3rb3g/Fz2/cFpY1s5zOzFXTl+YOwt9vhfJewHxlp79yVBCQ/rFOVy4wXS4GmGHy7DAZJt5YZmnq1P/fsnABqZqvbvtKInAuID+DWyF+HVMtx+iurpZ3GhhzI7H+8=}${[identity] \"}\"},\"id\":\"SmartContractCasino\"${[identity] \"}\"}']", gasForOraclize);
playerBetId[rngId] = rngId;
playerNumber[rngId] = rollUnder;
playerBetValue[rngId] = msg.value;
playerAddress[rngId] = msg.sender;
playerProfit[rngId] = ((((msg.value * (100 - (safeSub(rollUnder, 1)))) / (safeSub(rollUnder,1)) + msg.value)) *houseEdge / houseEdgeDivisor) - msg.value;
maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
require(maxPendingPayouts < contractBalance);
LogBet(playerBetId[rngId], playerAddress[rngId], safeAdd(playerBetValue[rngId], playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId]);
}
function __callback(bytes32 myid, string result, bytes proof) public
onlyOraclize
payoutsAreActive
{
require(playerAddress[myid] != 0x0);
var sl_result = result.toSlice();
sl_result.beyond("[".toSlice()).until("]".toSlice());
uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());
playerDieResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());
playerTempAddress[myid] = playerAddress[myid];
delete playerAddress[myid];
playerTempReward[myid] = playerProfit[myid];
playerProfit[myid] = 0;
maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);
playerTempBetValue[myid] = playerBetValue[myid];
playerBetValue[myid] = 0;
if (playerDieResult[myid]== 0 || bytes(result).length == 0 || bytes(proof).length == 0){
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerTempBetValue[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 3, proof);
if (!playerTempAddress[myid].send(playerTempBetValue[myid])){
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerTempBetValue[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 4, proof);
playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);
}
return;
}
if (playerDieResult[myid] < playerNumber[myid]){
contractBalance = safeSub(contractBalance, playerTempReward[myid]);
totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);
playerTempReward[myid] = safeAdd(playerTempReward[myid], playerTempBetValue[myid]);
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerTempBetValue[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 1, proof);
setMaxProfit();
if (!playerTempAddress[myid].send(playerTempReward[myid])){
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerTempBetValue[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 2, proof);
playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);
}
return;
}
if (playerDieResult[myid] >= playerNumber[myid]){
LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerTempBetValue[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 0, proof);
contractBalance = safeAdd(contractBalance, (playerTempBetValue[myid] - 1));
setMaxProfit();
if (!playerTempAddress[myid].send(1)){
playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);
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
function setMaxProfit() internal {
maxProfit = (contractBalance * maxProfitAsPercentOfHouse) / maxProfitDivisor;
}
function sendFunds()
payable
onlyTreasury
{
contractBalance = safeAdd(contractBalance, msg.value);
setMaxProfit();
}
function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public
onlyOwner
{
gasForOraclize = newSafeGasToOraclize;
}
function ownerUpdateContractBalance(uint newContractBalanceInWei) public
onlyOwner
{
contractBalance = newContractBalanceInWei;
}
function ownerSetHouseEdge(uint newHouseEdge) public
onlyOwner
{
houseEdge = newHouseEdge;
}
function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public
onlyOwner
{
require(newMaxProfitAsPercent <= 100000);
maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
setMaxProfit();
}
function ownerSetMinBet(uint newMinimumBet) public
onlyOwner
{
minBet = newMinimumBet;
}
function ownerTransferEther(address sendTo, uint amount) public
onlyOwner
{
contractBalance = safeSub(contractBalance, amount);
setMaxProfit();
require(sendTo.send(amount));
LogOwnerTransfer(sendTo, amount);
}
function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public
onlyOwner
{
maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);
require(sendTo.send(originalPlayerBetValue));
LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);
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
