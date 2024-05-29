contract State is Constants {
  address internal addressOfOwner;
  uint internal maxTime = 0;
  uint internal addedTime = 0;
  uint internal totalPot = 0;
  uint internal startTime = 0;
  uint internal endTime = 0;
  bool internal potWithdrawn = false;
  address internal addressOfCaptain;
  struct Info {
    address referral;
    uint countryId;
    uint withdrawn;
    string nick;
  }
  mapping (address => Info) internal infoOfAddress;
  mapping (address => string[]) internal codesOfAddress;
  mapping (string => address) internal addressOfCode;
  modifier restricted () {
    require(msg.sender == addressOfOwner);
    _;
  }
  modifier active () {
    require(startTime > 0);
    require(block.timestamp < endTime);
    require(!potWithdrawn);
    _;
  }
  modifier player () {
    require(infoOfAddress[msg.sender].countryId > 0);
    _;
  }
}
