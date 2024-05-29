contract StandardTokenExt is StandardToken, ERC827Token, Recoverable {
  function isToken() public constant returns (bool weAre) {
    return true;
  }
}
