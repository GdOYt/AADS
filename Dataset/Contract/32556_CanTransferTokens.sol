contract CanTransferTokens is CheckPayloadSize, Owned {
  function transferCustomToken(address _token, address _to, uint256 _value) onlyPayloadSize(3 * 32) onlyOwner public returns (bool) {
    Token tkn = Token(_token);
    return tkn.transfer(_to, _value);
  }
}
