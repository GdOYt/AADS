contract ReservedTokensFinalizeAgent is FinalizeAgent {
  using SafeMathLibExt for uint;
  CrowdsaleTokenExt public token;
  CrowdsaleExt public crowdsale;
  uint public distributedReservedTokensDestinationsLen = 0;
  function ReservedTokensFinalizeAgent(CrowdsaleTokenExt _token, CrowdsaleExt _crowdsale) public {
    token = _token;
    crowdsale = _crowdsale;
  }
  function isSane() public constant returns (bool) {
    return (token.releaseAgent() == address(this));
  }
  function distributeReservedTokens(uint reservedTokensDistributionBatch) public {
    assert(msg.sender == address(crowdsale));
    assert(reservedTokensDistributionBatch > 0);
    assert(!reservedTokensAreDistributed);
    assert(distributedReservedTokensDestinationsLen < token.reservedTokensDestinationsLen());
    uint tokensSold = 0;
    for (uint8 i = 0; i < crowdsale.joinedCrowdsalesLen(); i++) {
      CrowdsaleExt tier = CrowdsaleExt(crowdsale.joinedCrowdsales(i));
      tokensSold = tokensSold.plus(tier.tokensSold());
    }
    uint startLooping = distributedReservedTokensDestinationsLen;
    uint batch = token.reservedTokensDestinationsLen().minus(distributedReservedTokensDestinationsLen);
    if (batch >= reservedTokensDistributionBatch) {
      batch = reservedTokensDistributionBatch;
    }
    uint endLooping = startLooping + batch;
    for (uint j = startLooping; j < endLooping; j++) {
      address reservedAddr = token.reservedTokensDestinations(j);
      if (!token.areTokensDistributedForAddress(reservedAddr)) {
        uint allocatedBonusInPercentage;
        uint allocatedBonusInTokens = token.getReservedTokens(reservedAddr);
        uint percentsOfTokensUnit = token.getReservedPercentageUnit(reservedAddr);
        uint percentsOfTokensDecimals = token.getReservedPercentageDecimals(reservedAddr);
        if (percentsOfTokensUnit > 0) {
          allocatedBonusInPercentage = tokensSold * percentsOfTokensUnit / 10**percentsOfTokensDecimals / 100;
          token.mint(reservedAddr, allocatedBonusInPercentage);
        }
        if (allocatedBonusInTokens > 0) {
          token.mint(reservedAddr, allocatedBonusInTokens);
        }
        token.finalizeReservedAddress(reservedAddr);
        distributedReservedTokensDestinationsLen++;
      }
    }
    if (distributedReservedTokensDestinationsLen == token.reservedTokensDestinationsLen()) {
      reservedTokensAreDistributed = true;
    }
  }
  function finalizeCrowdsale() public {
    assert(msg.sender == address(crowdsale));
    if (token.reservedTokensDestinationsLen() > 0) {
      assert(reservedTokensAreDistributed);
    }
    token.releaseTokenTransfer();
  }
}
