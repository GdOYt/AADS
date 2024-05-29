contract ERC20 {
  uint256 public totalSupply;
  function transfer(address _to, uint256 _value) public returns(bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
  function balanceOf(address _owner) constant public returns(uint256 balance);
  function approve(address _spender, uint256 _value) public returns(bool success);
  function allowance(address _owner, address _spender) constant public returns(uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}