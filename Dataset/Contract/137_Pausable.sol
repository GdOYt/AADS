contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}
