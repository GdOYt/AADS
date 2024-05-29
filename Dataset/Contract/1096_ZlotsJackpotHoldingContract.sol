contract ZlotsJackpotHoldingContract {
  function payOutWinner(address winner) public; 
  function getJackpot() public view returns (uint);
}
