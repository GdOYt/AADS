contract WinnerWinner is Core, Internal, ExternalView {
  using SafeMath for *;
  constructor () public {
    addressOfOwner = msg.sender;
  }
  function () public payable {
    buy(addressOfOwner, DEFAULT_COUNTRY);
  }
  function start (uint _maxTime, uint _addedTime) public restricted {
    require(startTime == 0);
    require(_maxTime > 0 && _addedTime > 0);
    require(_maxTime > _addedTime);
    maxTime = _maxTime;
    addedTime = _addedTime;
    startTime = block.timestamp;
    endTime = startTime + maxTime;
    addressOfCaptain = addressOfOwner;
    _registerReferral("owner", addressOfOwner);
    emit Started(startTime);
  }
  function buy (address _referral, uint _countryId) public payable active {
    require(msg.value >= Utils.regularTicketPrice());
    require(msg.value <= 100000 ether);
    require(codesOfAddress[_referral].length > 0);
    require(_countryId != MAIN_SCHEME);
    require(Utils.validCountryId(_countryId));
    (uint tickets, uint excess) = Utils.ticketsForWithExcess(msg.value);
    uint value = msg.value.sub(excess);
    require(tickets > 0);
    require(value.add(excess) == msg.value);
    Info storage info = infoOfAddress[msg.sender];
    if (info.countryId == 0) {
      info.referral = _referral;
      info.countryId = _countryId;
    }
    uint vdivs = Utils.percentageOf(value, TO_DIVIDENDS);
    uint vreferral = Utils.percentageOf(value, TO_REFERRAL);
    uint vdevs = Utils.percentageOf(value, TO_DEVELOPERS);
    uint vcountry = Utils.percentageOf(value, TO_COUNTRY);
    uint vpot = value.sub(vdivs).sub(vreferral).sub(vdevs).sub(vcountry);
    assert(vdivs.add(vreferral).add(vdevs).add(vcountry).add(vpot) == value);
    buyShares(MAIN_SCHEME, msg.sender, tickets, vdivs);
    buyShares(info.countryId, msg.sender, tickets, vcountry);
    creditVault(MAIN_SCHEME, info.referral, vreferral);
    creditVault(MAIN_SCHEME, addressOfOwner, vdevs);
    if (excess > 0) {
      creditVault(MAIN_SCHEME, msg.sender, excess);
    }
    uint goldenTickets = value.div(Utils.goldenTicketPrice(totalPot));
    if (goldenTickets > 0) {
      endTime = endTime.add(goldenTickets.mul(addedTime)) > block.timestamp.add(maxTime) ?
        block.timestamp.add(maxTime) : endTime.add(goldenTickets.mul(addedTime));
      addressOfCaptain = msg.sender;
      emit Promoted(addressOfCaptain, goldenTickets, endTime);
    }
    totalPot = totalPot.add(vpot);
    emit Bought(msg.sender, info.referral, info.countryId, tickets, value, excess);
  }
  function setNick (string _nick) public payable {
    require(msg.value == SET_NICK_FEE);
    require(Utils.validNick(_nick));
    infoOfAddress[msg.sender].nick = _nick;
    creditVault(MAIN_SCHEME, addressOfOwner, msg.value);
  }
  function registerCode (string _code) public payable {
    require(startTime > 0);
    require(msg.value == REFERRAL_REGISTRATION_FEE);
    _registerReferral(_code, msg.sender);
    creditVault(MAIN_SCHEME, addressOfOwner, msg.value);
  }
  function giftCode (string _code, address _referral) public restricted {
    _registerReferral(_code, _referral);
  }
  function withdraw () public {
    Info storage info = infoOfAddress[msg.sender];
    uint payout = withdrawVault(MAIN_SCHEME, msg.sender);
    if (Utils.validCountryId(info.countryId)) {
      payout = payout.add(withdrawVault(info.countryId, msg.sender));
    }
    if (payout > 0) {
      info.withdrawn = info.withdrawn.add(payout);
      msg.sender.transfer(payout);
      emit Withdrew(msg.sender, payout);
    }
  }
  function withdrawPot () public player {
    require(startTime > 0);
    require(block.timestamp > (endTime + 10 minutes));
    require(!potWithdrawn);
    require(totalPot > 0);
    require(addressOfCaptain == msg.sender);
    uint payout = totalPot;
    totalPot = 0;
    potWithdrawn = true;
    addressOfCaptain.transfer(payout);
    emit Won(msg.sender, payout);
  }
}
