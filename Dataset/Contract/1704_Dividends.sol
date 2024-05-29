contract Dividends {
  using SafeMath for *;
  uint private constant FIXED_POINT = 1000000000000000000;
  struct Scheme {
    uint value;
    uint shares;
    uint mask;
  }
  struct Vault {
    uint value;
    uint shares;
    uint mask;
  }
  mapping (uint => mapping (address => Vault)) private vaultOfAddress;
  mapping (uint => Scheme) private schemeOfId;
  function buyShares (uint _schemeId, address _owner, uint _shares, uint _value) internal {
    require(_owner != address(0));
    require(_shares > 0 && _value > 0);
    uint value = _value.mul(FIXED_POINT);
    Scheme storage scheme = schemeOfId[_schemeId];
    scheme.value = scheme.value.add(_value);
    scheme.shares = scheme.shares.add(_shares);
    require(value > scheme.shares);
    uint pps = value.div(scheme.shares);
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    vault.shares = vault.shares.add(_shares);
    vault.mask = vault.mask.add(scheme.mask.mul(_shares));
    vault.value = vault.value.add(value.sub(pps.mul(scheme.shares)));
    scheme.mask = scheme.mask.add(pps);
  }
  function flushVault (uint _schemeId, address _owner) internal {
    uint gains = gainsOfVault(_schemeId, _owner);
    if (gains > 0) {
      Vault storage vault = vaultOfAddress[_schemeId][_owner];
      vault.value = vault.value.add(gains);
      vault.mask = vault.mask.add(gains);
    }
  }
  function withdrawVault (uint _schemeId, address _owner) internal returns (uint) {
    flushVault(_schemeId, _owner);
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    uint payout = vault.value.div(FIXED_POINT);
    if (payout > 0) {
      vault.value = 0;
    }
    return payout;
  }
  function creditVault (uint _schemeId, address _owner, uint _value) internal {
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    vault.value = vault.value.add(_value.mul(FIXED_POINT));
  }
  function gainsOfVault (uint _schemeId, address _owner) internal view returns (uint) {
    Scheme storage scheme = schemeOfId[_schemeId];
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    if (vault.shares == 0) {
      return 0;
    }
    return scheme.mask.mul(vault.shares).sub(vault.mask);
  }
  function valueOfVault (uint _schemeId, address _owner) internal view returns (uint) {
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    return vault.value;
  }
  function balanceOfVault (uint _schemeId, address _owner) internal view returns (uint) {
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    uint total = vault.value.add(gainsOfVault(_schemeId, _owner));
    uint balance = total.div(FIXED_POINT);
    return balance;
  }
  function sharesOfVault (uint _schemeId, address _owner) internal view returns (uint) {
    Vault storage vault = vaultOfAddress[_schemeId][_owner];
    return vault.shares;
  }
  function valueOfScheme (uint _schemeId) internal view returns (uint) {
    return schemeOfId[_schemeId].value;
  }
  function sharesOfScheme (uint _schemeId) internal view returns (uint) {
    return schemeOfId[_schemeId].shares;
  }
}
