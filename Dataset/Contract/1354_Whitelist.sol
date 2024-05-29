contract Whitelist is Ownable {
  address whitelisted;
  modifier onlyWhitelisted() {
    require(msg.sender == owner || msg.sender == whitelisted);
    _;
  }
  function whitelist(address _toWhitelist) public onlyOwner
  {
    whitelisted = _toWhitelist;
  }
}
