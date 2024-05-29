contract CustomPausable is CustomWhitelist {
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
  function pause() onlyWhitelisted whenNotPaused public {
    paused = true;
    emit Pause();
  }
  function unpause() onlyWhitelisted whenPaused public {
    paused = false;
    emit Unpause();
  }
}
