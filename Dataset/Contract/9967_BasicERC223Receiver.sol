contract BasicERC223Receiver {
  function tokenFallback(address _from, uint256 _value, bytes _data) public pure;
}
