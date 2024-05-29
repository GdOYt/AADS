contract TestTokenAPreICO is CappedCrowdsale, RefundableCrowdsale, Destructible, Pausable {
  function TestTokenAPreICO(address _tokenAddress, uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap, address _wallet)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    Crowdsale(_tokenAddress, _startTime, _endTime, _rate, _wallet)
  {
    require(_goal <= _cap);
  }
}
