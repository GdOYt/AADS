contract ERC20 {
  function balanceOf(address owner) constant returns (uint balance);
  function transfer(address to, uint value) returns (bool success);
}
