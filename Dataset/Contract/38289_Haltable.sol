contract Haltable is Controlled {
  bool public halted;
  modifier stopInEmergency {
    if (halted) throw;
    _;
  }
  modifier onlyInEmergency {
    if (!halted) throw;
    _;
  }
  function halt() external onlyController {
    halted = true;
  }
  function unhalt() external onlyController onlyInEmergency {
    halted = false;
  }
}
