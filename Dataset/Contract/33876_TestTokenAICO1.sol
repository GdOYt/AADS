contract TestTokenAICO1 is CappedCrowdsale, Destructible, Pausable {
  function TestTokenAICO1(address _tokenAddress, uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet)
    CappedCrowdsale(_cap)
    Crowdsale(_tokenAddress, _startTime, _endTime, _rate, _wallet)
  {
  }
}
