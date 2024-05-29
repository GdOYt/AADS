contract PEpsilon {
  Pinakion public pinakion;
  Kleros public court;
  uint public balance;
  uint public disputeID;
  uint public desiredOutcome;
  uint public epsilon;
  bool public settled;
  uint public maxAppeals;  
  mapping (address => uint) public withdraw;  
  address public attacker;
  uint public remainingWithdraw;  
  modifier onlyBy(address _account) {require(msg.sender == _account); _;}
  event AmountShift(uint val, uint epsilon ,address juror);
  event Log(uint val, address addr, string message);
  constructor(Pinakion _pinakion, Kleros _kleros, uint _disputeID, uint _desiredOutcome, uint _epsilon, uint _maxAppeals) public {
    pinakion = _pinakion;
    court = _kleros;
    disputeID = _disputeID;
    desiredOutcome = _desiredOutcome;
    epsilon = _epsilon;
    attacker = msg.sender;
    maxAppeals = _maxAppeals;
  }
  function receiveApproval(address _from, uint _amount, address, bytes) public onlyBy(pinakion) {
    require(pinakion.transferFrom(_from, this, _amount));
    balance += _amount;
  }
  function withdrawJuror() {
    withdrawSelect(msg.sender);
  }
  function withdrawSelect(address _juror) {
    uint amount = withdraw[_juror];
    withdraw[_juror] = 0;
    balance = sub(balance, amount);  
    remainingWithdraw = sub(remainingWithdraw, amount);
    require(pinakion.transfer(_juror, amount));
  }
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }
  function withdrawAttacker(){
    require(settled);
    if (balance > remainingWithdraw) {
      uint amount = balance - remainingWithdraw;
      balance = remainingWithdraw;
      require(pinakion.transfer(attacker, amount));
    }
  }
  function settle() public {
    require(court.disputeStatus(disputeID) ==  Arbitrator.DisputeStatus.Solved);  
    require(!settled);  
    settled = true;  
    var (, , appeals, choices, , , ,) = court.disputes(disputeID);
    if (court.currentRuling(disputeID) != desiredOutcome){
      uint amountShift = court.getStakePerDraw();
      uint winningChoice = court.getWinningChoice(disputeID, appeals);
      for (uint i=0; i <= (appeals > maxAppeals ? maxAppeals : appeals); i++){  
        if (winningChoice != 0){
          uint votesLen = 0;
          for (uint c = 0; c <= choices; c++) {  
            votesLen += court.getVoteCount(disputeID, i, c);
          }
          emit Log(amountShift, 0x0 ,"stakePerDraw");
          emit Log(votesLen, 0x0, "votesLen");
          uint totalToRedistribute = 0;
          uint nbCoherent = 0;
          for (uint j=0; j < votesLen; j++){
            uint voteRuling = court.getVoteRuling(disputeID, i, j);
            address voteAccount = court.getVoteAccount(disputeID, i, j);
            emit Log(voteRuling, voteAccount, "voted");
            if (voteRuling != winningChoice){
              totalToRedistribute += amountShift;
              if (voteRuling == desiredOutcome){  
                withdraw[voteAccount] += amountShift + epsilon;
                remainingWithdraw += amountShift + epsilon;
                emit AmountShift(amountShift, epsilon, voteAccount);
              }
            } else {
              nbCoherent++;
            }
          }
          uint toRedistribute = (totalToRedistribute - amountShift) / (nbCoherent + 1);
          for (j = 0; j < votesLen; j++){
            voteRuling = court.getVoteRuling(disputeID, i, j);
            voteAccount = court.getVoteAccount(disputeID, i, j);
            if (voteRuling == desiredOutcome){
              withdraw[voteAccount] += toRedistribute;
              remainingWithdraw += toRedistribute;
              emit AmountShift(toRedistribute, 0, voteAccount);
            }
          }
        }
      }
    }
  }
}
