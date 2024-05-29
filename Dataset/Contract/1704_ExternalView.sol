contract ExternalView is Core {
  function totalInfo () external view returns (bool, bool, address, uint, uint, uint, uint, uint, uint, address) {
    return (
      startTime > 0,
      block.timestamp >= endTime,
      addressOfCaptain,
      totalPot,
      endTime,
      sharesOfScheme(MAIN_SCHEME),
      valueOfScheme(MAIN_SCHEME),
      maxTime,
      addedTime,
      addressOfOwner
    );
  }
  function countryInfo (uint _countryId) external view returns (uint, uint) {
    return (
      sharesOfScheme(_countryId),
      valueOfScheme(_countryId)
    );
  }
  function playerInfo (address _player) external view returns (uint, uint, uint, address, uint, uint, string) {
    Info storage info = infoOfAddress[_player];
    return (
      sharesOfVault(MAIN_SCHEME, _player),
      balanceOfVault(MAIN_SCHEME, _player),
      balanceOfVault(info.countryId, _player),
      info.referral,
      info.countryId,
      info.withdrawn,
      info.nick
    );
  }
  function numberOfReferralCodes (address _player) external view returns (uint) {
    return codesOfAddress[_player].length;
  }
  function referralCodeAt (address _player, uint i) external view returns (string) {
    return codesOfAddress[_player][i];
  }
  function codeToAddress (string _code) external view returns (address) {
    return addressOfCode[_code];
  }
  function goldenTicketPrice (uint _x) external pure returns (uint) {
    return Utils.goldenTicketPrice(_x);
  }
}
