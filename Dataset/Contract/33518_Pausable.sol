contract Pausable is Governable {
  bool public paused = true;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() onlyAdmins whenNotPaused {
    paused = true;
  }
  function unpause() onlyAdmins whenPaused {
    paused = false;
  }
}
