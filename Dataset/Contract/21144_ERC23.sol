contract ERC23 {
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool success);
}
