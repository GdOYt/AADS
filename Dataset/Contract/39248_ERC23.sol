contract ERC23 {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function allowance(address owner, address spender) constant returns (uint256);
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);
  function transfer(address to, uint256 value) returns (bool ok);
  function transfer(address to, uint256 value, bytes data) returns (bool ok);
  function transferFrom(address from, address to, uint256 value) returns (bool ok);
  function approve(address spender, uint256 value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
