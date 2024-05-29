contract Buyer {
  mapping (address => uint256) public balances;
  uint256 public buy_bounty;
  uint256 public withdraw_bounty;
  bool public bought_tokens;
  uint256 public contract_eth_value;
  bool public kill_switch;
  bytes32 password_hash = 0xbeb7247422d4e22a0cf0085c07b37aca88a1958e4da1ca1947e53a5adf5c0499;
  uint256 public earliest_buy_time = 1505304000;
  uint256 public eth_cap = 5000 ether;
  address public developer = 0x53b1606bc4540f90daad2b05110f6cc0b42daefa;
  address public sale = 0x8b7B6C61238088593BF75eEC8FBF58D0a615d30c;
  ERC20 public token = ERC20(0x0d88eD6E74bbFD96B831231638b66C05571e824F);
  function activate_kill_switch(string password) {
    require(msg.sender == developer || sha3(password) == password_hash);
    kill_switch = true;
  }
  function withdraw(address user){
    require(bought_tokens || now > earliest_buy_time + 1 hours);
    if (balances[user] == 0) return;
    if (!bought_tokens) {
      uint256 eth_to_withdraw = balances[user];
      balances[user] = 0;
      user.transfer(eth_to_withdraw);
    }
    else {
      uint256 contract_token_balance = token.balanceOf(address(this));
      require(contract_token_balance != 0);
      uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
      contract_eth_value -= balances[user];
      balances[user] = 0;
      uint256 fee = tokens_to_withdraw / 200;
      require(token.transfer(developer, fee));
      require(token.transfer(user, tokens_to_withdraw - fee));
    }
  }
  function add_to_buy_bounty() payable {
    require(msg.sender == developer);
    buy_bounty += msg.value;
  }
  function claim_bounty(){
    if (bought_tokens) return;
    if (now < earliest_buy_time) return;
    if (kill_switch) return;
    require(sale != 0x0);
    bought_tokens = true;
    uint256 claimed_bounty = buy_bounty;
    buy_bounty = 0;
    contract_eth_value = this.balance - (claimed_bounty + withdraw_bounty);
    require(sale.call.value(contract_eth_value)());
    msg.sender.transfer(claimed_bounty);
  }
  function () payable {
    require(!kill_switch);
    require(!bought_tokens);
    require(this.balance < eth_cap);
    balances[msg.sender] += msg.value;
  }
}
