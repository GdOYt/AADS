contract Haltable is Ownable {
  bool public halted = false;
  modifier inNormalState {
    require(!halted);
    _;
  }
  modifier inEmergencyState {
    require(halted);
    _;
  }
  function halt() external onlyOwner inNormalState {
    halted = true;
  }
  function unhalt() external onlyOwner inEmergencyState {
    halted = false;
  }
}
