contract ERC20 {
  function balanceOf (address owner) public view returns (uint256);
  function allowance (address owner, address spender) public view returns (uint256);
  function transfer (address to, uint256 value) public returns (bool);
  function transferFrom (address from, address to, uint256 value) public returns (bool);
  function approve (address spender, uint256 value) public returns (bool);
}
