contract NullFinalizeAgentExt is FinalizeAgent {
  CrowdsaleExt public crowdsale;
  function NullFinalizeAgentExt(CrowdsaleExt _crowdsale) {
    crowdsale = _crowdsale;
  }
  function isSane() public constant returns (bool) {
    return true;
  }
  function distributeReservedTokens(uint reservedTokensDistributionBatch) public {
  }
  function finalizeCrowdsale() public {
  }
}
