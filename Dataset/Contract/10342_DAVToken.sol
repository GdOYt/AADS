contract DAVToken is IDAVToken, BurnableToken, OwnedPausableToken {
  string public name = 'DAV Token';
  string public symbol = 'DAV';
  uint8 public decimals = 18;
  uint256 public pauseCutoffTime;
  constructor(uint256 _initialSupply) public {
    totalSupply_ = _initialSupply;
    balances[msg.sender] = totalSupply_;
  }
  function setPauseCutoffTime(uint256 _pauseCutoffTime) onlyOwner public {
    require(_pauseCutoffTime >= block.timestamp);
    require(pauseCutoffTime == 0);
    pauseCutoffTime = _pauseCutoffTime;
  }
  function pause() onlyOwner whenNotPaused public {
    require(pauseCutoffTime == 0 || pauseCutoffTime >= block.timestamp);
    paused = true;
    emit Pause();
  }
}
