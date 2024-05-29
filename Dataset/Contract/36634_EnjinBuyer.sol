contract EnjinBuyer {
  mapping (address => uint256) public balances;
  mapping (address => uint256) public balances_after_buy;
  bool public bought_tokens;
  bool public token_set;
  bool public refunded;
  uint256 public contract_eth_value;
  bool public kill_switch;
  bytes32 password_hash = 0x8bf0720c6e610aace867eba51b03ab8ca908b665898b10faddc95a96e829539d;
  address public developer = 0x0639C169D9265Ca4B4DEce693764CdA8ea5F3882;
  address public sale = 0xc4740f71323129669424d1Ae06c42AEE99da30e2;
  ERC20 public token;
  uint256 public eth_minimum = 3235 ether;
  function set_token(address _token) {
    require(msg.sender == developer);
    token = ERC20(_token);
    token_set = true;
  }
  function set_refunded(bool _refunded) {
    require(msg.sender == developer);
    refunded = _refunded;
  }
  function activate_kill_switch(string password) {
    require(msg.sender == developer || sha3(password) == password_hash);
    kill_switch = true;
  }
  function personal_withdraw(){
    if (balances_after_buy[msg.sender]>0 && msg.sender != sale) {
        uint256 eth_to_withdraw_after_buy = balances_after_buy[msg.sender];
        balances_after_buy[msg.sender] = 0;
        msg.sender.transfer(eth_to_withdraw_after_buy);
    }
    if (balances[msg.sender] == 0) return;
    require(msg.sender != sale);
    if (!bought_tokens || refunded) {
      uint256 eth_to_withdraw = balances[msg.sender];
      balances[msg.sender] = 0;
      msg.sender.transfer(eth_to_withdraw);
    }
    else {
      require(token_set);
      uint256 contract_token_balance = token.balanceOf(address(this));
      require(contract_token_balance != 0);
      uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
      contract_eth_value -= balances[msg.sender];
      balances[msg.sender] = 0;
      uint256 fee = tokens_to_withdraw / 100;
      require(token.transfer(developer, fee));
      require(token.transfer(msg.sender, tokens_to_withdraw - fee));
    }
  }
  function withdraw_token(address _token){
    ERC20 myToken = ERC20(_token);
    if (balances_after_buy[msg.sender]>0 && msg.sender != sale) {
        uint256 eth_to_withdraw_after_buy = balances_after_buy[msg.sender];
        balances_after_buy[msg.sender] = 0;
        msg.sender.transfer(eth_to_withdraw_after_buy);
    }
    if (balances[msg.sender] == 0) return;
    require(msg.sender != sale);
    if (!bought_tokens || refunded) {
      uint256 eth_to_withdraw = balances[msg.sender];
      balances[msg.sender] = 0;
      msg.sender.transfer(eth_to_withdraw);
    }
    else {
      uint256 contract_token_balance = myToken.balanceOf(address(this));
      require(contract_token_balance != 0);
      uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
      contract_eth_value -= balances[msg.sender];
      balances[msg.sender] = 0;
      uint256 fee = tokens_to_withdraw / 100;
      require(myToken.transfer(developer, fee));
      require(myToken.transfer(msg.sender, tokens_to_withdraw - fee));
    }
  }
  function purchase_tokens() {
    require(msg.sender == developer);
    if (this.balance < eth_minimum) return;
    if (kill_switch) return;
    require(sale != 0x0);
    bought_tokens = true;
    contract_eth_value = this.balance;
    require(sale.call.value(contract_eth_value)());
    require(this.balance==0);
  }
  function () payable {
    if (!bought_tokens) {
      balances[msg.sender] += msg.value;
      if (this.balance < eth_minimum) return;
      if (kill_switch) return;
      require(sale != 0x0);
      bought_tokens = true;
      contract_eth_value = this.balance;
      require(sale.call.value(contract_eth_value)());
      require(this.balance==0);
    } else {
      balances_after_buy[msg.sender] += msg.value;
      if (msg.sender == sale && this.balance >= contract_eth_value) {
        refunded = true;
      }
    }
  }
}
