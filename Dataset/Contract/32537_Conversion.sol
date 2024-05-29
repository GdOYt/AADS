contract Conversion is CanTransferTokens, useContractWeb {
  function token1stContract() view internal returns (address) {
    return web.getContractAddress("Token1st");
  }
  function tokenContract() view internal returns (address) {
    return web.getContractAddress("Token");
  }
  function deposit() onlyOwner public returns (bool) {
    require(Token(tokenContract()).allowance(owner, this) > 0);
    return Token(tokenContract()).transferFrom(owner, this, Token(tokenContract()).allowance(owner, this));
  }
  function convert() public returns (bool) {
    uint256 senderBalance = Token1st(token1stContract()).getBalanceOf(msg.sender);
    require(Token1st(token1stContract()).allowance(msg.sender, this) >= senderBalance);
    Token1st(token1stContract()).transferDecimalAmountFrom(msg.sender, owner, senderBalance);
    return Token(tokenContract()).transfer(msg.sender, senderBalance * 10000000000);
  }
}
