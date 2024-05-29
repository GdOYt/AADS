contract FinalizeAgent {
  function isFinalizeAgent() public constant returns(bool) {
    return true;
  }
  function isSane() public constant returns (bool);
  function finalizeCrowdsale();
}
