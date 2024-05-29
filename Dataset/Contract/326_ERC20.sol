contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
