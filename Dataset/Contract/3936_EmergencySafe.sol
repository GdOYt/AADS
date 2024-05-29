contract EmergencySafe is Ownable{ 
  event PauseToggled(bool isPaused);
  bool public paused;
  modifier isNotPaused() {
    require(!paused);
    _;
  }
  modifier isPaused() {
    require(paused);
    _; 
  }
  function EmergencySafe() public {
    paused = false;
  }
  function emergencyERC20Drain(ERC20Interface token, uint amount) public ownerOnly{
    token.transfer(owner, amount);
  }
  function emergencyEthDrain(uint amount) public ownerOnly returns (bool){
    return owner.send(amount);
  }
  function togglePause() public ownerOnly {
    paused = !paused;
    emit PauseToggled(paused);
  }
}
