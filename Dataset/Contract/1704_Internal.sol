contract Internal is Core {
  function _registerReferral (string _code, address _referral) internal {
    require(Utils.validReferralCode(_code));
    require(addressOfCode[_code] == address(0));
    addressOfCode[_code] = _referral;
    codesOfAddress[_referral].push(_code);
    emit Registered(_code, _referral);
  }
}
