contract CentralizedBugOracle is Proxied,Oracle, CentralizedBugOracleData{
  function setOutcome(int _outcome)
      public
      isOwner
  {
      require(!isSet);
      _setOutcome(_outcome);
  }
  function isOutcomeSet()
      public
      view
      returns (bool)
  {
      return isSet;
  }
  function getOutcome()
      public
      view
      returns (int)
  {
      return outcome;
  }
  function _setOutcome(int _outcome) internal {
    isSet = true;
    outcome = _outcome;
    emit OutcomeAssignment(_outcome);
  }
}
