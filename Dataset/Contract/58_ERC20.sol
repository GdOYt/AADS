contract ERC20 is ERC20Basic {
  mapping(address => uint) balances;
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value) returns (bool);
  function approve(address spender, uint value) returns (bool);
  function approveAndCall(address spender, uint256 value, bytes extraData) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint value);
  function doTransfer(address _from, address _to, uint _amount) internal returns(bool);
}
