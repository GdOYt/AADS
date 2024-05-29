contract Token {
  function balanceOf(address _owner) public returns (uint256); 
  function transfer(address to, uint256 tokens) public returns (bool);
  function transferFrom(address from, address to, uint256 tokens) public returns(bool);
}
