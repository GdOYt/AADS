contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;
  bool public isFinalized = false;
  event Finalized();
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());
    finalization();
    emit Finalized();
    isFinalized = true;
  }
  function finalization() internal {
  }
}
