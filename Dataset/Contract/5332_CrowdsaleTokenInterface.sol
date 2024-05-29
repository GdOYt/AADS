contract CrowdsaleTokenInterface {
  uint public decimals;
  function addLockAddress(address addr, uint lock_time) public;
  function mint(address _to, uint256 _amount) public returns (bool);
  function finishMinting() public returns (bool);
}
