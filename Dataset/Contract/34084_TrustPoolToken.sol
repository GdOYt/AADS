contract TrustPoolToken is StandardToken {
  string public constant name = "Trust Pool Token";
  string public constant symbol = "TPL";
  uint public constant decimals = 10;
  uint256 public initialSupply;
  ERC20 public sourceTokens = ERC20(0x9742fA8CB51d294C8267DDFEad8582E16f18e421);  
  address public manager = 0x36586ef28844D0f2587c4b565C6D57aA677Ef09E;  
  function TrustPoolToken() {
   totalSupply = 50000000 * 10 ** decimals;
   balances[msg.sender] = totalSupply;
   initialSupply = totalSupply;
   Transfer(0, this, totalSupply);
   Transfer(this, msg.sender, totalSupply);
  }
  function convert10MTI() external {
    uint256 balance = sourceTokens.balanceOf(msg.sender);
    uint256 allowed = sourceTokens.allowance(msg.sender, this); 
    uint256 tokensToTransfer = (balance < allowed) ? balance : allowed;
    sourceTokens.transferFrom(msg.sender, 0, tokensToTransfer);
    balances[manager] = balances[manager].sub(tokensToTransfer);
    balances[msg.sender] = balances[msg.sender].add(tokensToTransfer);
  }
}
