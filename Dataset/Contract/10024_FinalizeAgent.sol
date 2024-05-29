contract FinalizeAgent {
  bool public reservedTokensAreDistributed = false;
  function isFinalizeAgent() public constant returns(bool) {
    return true;
  }
  function isSane() public constant returns (bool);
  function distributeReservedTokens(uint reservedTokensDistributionBatch);
  function finalizeCrowdsale();
}
