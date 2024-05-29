contract YesNo is SafeMath {
  ReserveToken public yesToken;
  ReserveToken public noToken;
  bytes32 public factHash;
  address public ethAddr;
  string public url;
  uint public outcome;
  bool public resolved = false;
  address public feeAccount;
  uint public fee;  
  event Create(address indexed account, uint value);
  event Redeem(address indexed account, uint value, uint yesTokens, uint noTokens);
  event Resolve(bool resolved, uint outcome);
  function() {
    throw;
  }
  function YesNo(bytes32 factHash_, address ethAddr_, string url_, address feeAccount_, uint fee_) {
    yesToken = new ReserveToken();
    noToken = new ReserveToken();
    factHash = factHash_;
    ethAddr = ethAddr_;
    url = url_;
    feeAccount = feeAccount_;
    fee = fee_;
  }
  function create() {
    yesToken.create(msg.sender, msg.value);
    noToken.create(msg.sender, msg.value);
    Create(msg.sender, msg.value);
  }
  function redeem(uint tokens) {
    if (!feeAccount.call.value(safeMul(tokens,fee)/(1 ether))()) throw;
    if (!resolved) {
      yesToken.destroy(msg.sender, tokens);
      noToken.destroy(msg.sender, tokens);
      if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
      Redeem(msg.sender, tokens, tokens, tokens);
    } else if (resolved) {
      if (outcome==0) {  
        noToken.destroy(msg.sender, tokens);
        if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
        Redeem(msg.sender, tokens, 0, tokens);
      } else if (outcome==1) {  
        yesToken.destroy(msg.sender, tokens);
        if (!msg.sender.call.value(safeMul(tokens,(1 ether)-fee)/(1 ether))()) throw;
        Redeem(msg.sender, tokens, tokens, 0);
      }
    }
  }
  function resolve(uint8 v, bytes32 r, bytes32 s, bytes32 value) {
    if (ecrecover(sha3(factHash, value), v, r, s) != ethAddr) throw;
    if (resolved) throw;
    uint valueInt = uint(value);
    if (valueInt==0 || valueInt==1) {
      outcome = valueInt;
      resolved = true;
      Resolve(resolved, outcome);
    } else {
      throw;
    }
  }
}
