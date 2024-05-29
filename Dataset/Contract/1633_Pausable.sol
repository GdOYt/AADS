contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused {
    require(paused);
    _;
  }
  function pause() public onlyOwner whenNotPaused returns(bool) {
    paused = true;
    emit Pause();
    return true;
  }
  function unpause() public onlyOwner whenPaused returns(bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}
