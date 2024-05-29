contract Pausable is Ownable {
  event Pause();
  event Unpause();
  event FinalUnpause();
  bool public paused = false;
  bool public finalUnpaused = false;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() onlyOwner whenNotPaused public {
    require (!finalUnpaused);
    paused = true;
    emit Pause();
  }
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
  function finalUnpause() onlyOwner public {
    paused = false;
    emit FinalUnpause();
  }
}
