contract DeltaBalances {
  address public admin; 
  function DeltaBalances() public {
    admin = msg.sender;
  }
  function() public payable {
    revert();
  }
  modifier isAdmin() {
    require(msg.sender == admin);
    _;
  }
  function withdraw() external isAdmin {
    admin.transfer(address(this).balance);
  }
  function withdrawToken(address token, uint amount) external isAdmin {
    require(token != address(0x0) && Token(token).transfer(msg.sender, amount));
  }
  function deltaBalances(address exchange, address user,  address[] tokens) external view returns (uint[]) {
    Exchange ex = Exchange(exchange);
    uint[] memory balances = new uint[](tokens.length);
    for(uint i = 0; i < tokens.length; i++) {
      balances[i] = ex.balanceOf(tokens[i], user);
    }    
    return balances;
  }
  function multiDeltaBalances(address[] exchanges, address user,  address[] tokens) external view returns (uint[]) {
    uint[] memory balances = new uint[](tokens.length * exchanges.length);
    for(uint i = 0; i < exchanges.length; i++) {
      Exchange ex = Exchange(exchanges[i]);
      for(uint j = 0; j < tokens.length; j++) {
        balances[(j * exchanges.length) + i] = ex.balanceOf(tokens[j], user);
      }
    }
    return balances;
  }
  function tokenBalance(address user, address token) public view returns (uint) {
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) }  
    if(tokenCode > 0 && token.call(bytes4(keccak256("balanceOf(address)")), user)) {
      return Token(token).balanceOf(user);
    } else {
      return 0;  
    }
  }
  function walletBalances(address user,  address[] tokens) external view returns (uint[]) {
    require(tokens.length > 0);
    uint[] memory balances = new uint[](tokens.length);
    for(uint i = 0; i < tokens.length; i++) {
      if(tokens[i] != address(0x0)) { 
        balances[i] = tokenBalance(user, tokens[i]);
      } else {
        balances[i] = user.balance;  
      }
    }    
    return balances;
  }
  function allBalances(address exchange, address user,  address[] tokens) external view returns (uint[]) {
    Exchange ex = Exchange(exchange);
    uint[] memory balances = new uint[](tokens.length * 2);
    for(uint i = 0; i < tokens.length; i++) {
      uint j = i * 2;
      balances[j] = ex.balanceOf(tokens[i], user);
      if(tokens[i] != address(0x0)) {
        balances[j + 1] = tokenBalance(user, tokens[i]);
      } else {
        balances[j + 1] = user.balance;  
      }
    }
    return balances; 
  }
}
