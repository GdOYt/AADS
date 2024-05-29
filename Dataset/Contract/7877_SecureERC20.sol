contract SecureERC20 is ERC20 {
  event SetERC20ApproveChecking(bool approveChecking);
  function approve(address spender, uint256 expectedValue, uint256 newValue) public returns (bool);
  function increaseAllowance(address spender, uint256 value) public returns (bool);
  function decreaseAllowance(address spender, uint256 value, bool strict) public returns (bool);
  function setERC20ApproveChecking(bool approveChecking) public;
}
