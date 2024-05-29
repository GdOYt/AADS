contract ZTHInterface {
  function getFrontEndTokenBalanceOf(address who) public view returns (uint);
  function transfer(address _to, uint _value) public returns (bool);
  function approve(address spender, uint tokens) public returns (bool);
}
