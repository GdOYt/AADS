contract Haltable is Ownable {
  bool public halted;
  modifier stopInEmergency {
    if (halted) revert();
    _;
  }
  modifier onlyInEmergency {
    if (!halted) revert();
    _;
  }
  function halt() external onlyOwner {
    halted = true;
  }
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }
}
