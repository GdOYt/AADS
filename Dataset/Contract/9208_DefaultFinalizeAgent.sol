contract DefaultFinalizeAgent is FinalizeAgent {
  ReleasableToken public token;
  Crowdsale public crowdsale;
  function DefaultFinalizeAgent(ReleasableToken _token, Crowdsale _crowdsale) {
    token = _token;
    crowdsale = _crowdsale;
  }
  function isSane() public constant returns (bool) {
    return (token.releaseAgent() == address(this));
  }
  function finalizeCrowdsale() public {
    if (msg.sender != address(crowdsale)) {
      revert();
    }
    token.releaseTokenTransfer();
  }
}
