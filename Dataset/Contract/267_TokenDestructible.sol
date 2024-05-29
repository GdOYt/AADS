contract TokenDestructible is Ownable,FrozenableToken {
  constructor() public payable { }
  function destroy(address[] _tokens) public onlyOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      ERC20Basic token = ERC20Basic(_tokens[i]);
      uint256 balance = token.balanceOf(this);
      token.transfer(owner, balance);
    }
    selfdestruct(owner);
  }
}
