contract Distribution is CanTransferTokens, SafeMath, useContractWeb {
  uint256 public liveSince;
  uint256 public withdrawn;
  function withdrawnReadable() view public returns (uint256) {
    return withdrawn / 1000000000000000000;
  }
  function secondsLive() view public returns (uint256) {
    if(liveSince != 0) {
      return now - liveSince;
    }
  }
  function allowedSince() view public returns (uint256) {
    return secondsLive() * 380265185769276972;
  }
  function allowedSinceReadable() view public returns (uint256) {
    return secondsLive() * 380265185769276972 / 1000000000000000000;
  }
  function stillAllowed() view public returns (uint256) {
    return allowedSince() - withdrawn;
  }
  function stillAllowedReadable() view public returns (uint256) {
    uint256 _1 = allowedSince() - withdrawn;
    return _1 / 1000000000000000000;
  }
  function tokenContract() view internal returns (address) {
    return web.getContractAddress("Token");
  }
  function makeLive() onlyOwner public returns (bool) {
    require(liveSince == 0);
    liveSince = now;
    return true;
  }
  function deposit() onlyOwner public returns (bool) {
    require(Token(tokenContract()).allowance(owner, this) > 0);
    return Token(tokenContract()).transferFrom(owner, this, Token(tokenContract()).allowance(owner, this));
  }
  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
    require(stillAllowed() >= _value && _value > 0 && liveSince != 0);
    withdrawn = add(withdrawn, _value);
    return Token(tokenContract()).transfer(_to, _value);
  }
  function transferReadable(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
    require(stillAllowed() >= _value * 1000000000000000000 && stillAllowed() != 0 && liveSince != 0);
    withdrawn = add(withdrawn, _value * 1000000000000000000);
    return Token(tokenContract()).transfer(_to, _value * 1000000000000000000);
  }
}
