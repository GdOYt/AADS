contract WhitelistDaonomicCrowdsale is Ownable, DaonomicCrowdsale {
  Whitelist[] public whitelists;
  constructor (Whitelist[] _whitelists) public {
    whitelists = _whitelists;
  }
  function setWhitelists(Whitelist[] _whitelists) onlyOwner public {
    whitelists = _whitelists;
  }
  function getWhitelists() view public returns (Whitelist[]) {
    return whitelists;
  }
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  ) internal {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(canBuy(_beneficiary), "investor is not verified by Whitelists");
  }
  function canBuy(address _beneficiary) constant public returns (bool) {
    for (uint i = 0; i < whitelists.length; i++) {
      if (whitelists[i].isInWhitelist(_beneficiary)) {
        return true;
      }
    }
    return false;
  }
}
