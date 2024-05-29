contract WhitelistedCrowdsale is Ownable {
  mapping(address => bool) public whitelist;
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }
  function addToWhitelist(address _beneficiary) onlyOwner public  {
    whitelist[_beneficiary] = true;
  }
  function addManyToWhitelist(address[] _beneficiaries) onlyOwner public {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }
  function removeFromWhitelist(address _beneficiary)onlyOwner public {
    whitelist[_beneficiary] = false;
  }
}
