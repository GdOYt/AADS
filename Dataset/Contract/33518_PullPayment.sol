contract PullPayment is Ownable {
  using SafeMath for uint256;
  uint public dailyLimit = 1000000000000000000000;   
  uint public lastDay;
  uint public spentToday;
  mapping(address => uint256) internal payments;
  modifier onlyNutz() {
    require(msg.sender == ControllerInterface(owner).nutzAddr());
    _;
  }
  modifier whenNotPaused () {
    require(!ControllerInterface(owner).paused());
     _;
  }
  function balanceOf(address _owner) constant returns (uint256 value) {
    return uint192(payments[_owner]);
  }
  function paymentOf(address _owner) constant returns (uint256 value, uint256 date) {
    value = uint192(payments[_owner]);
    date = (payments[_owner] >> 192);
    return;
  }
  function changeDailyLimit(uint _dailyLimit) public onlyOwner {
      dailyLimit = _dailyLimit;
  }
  function changeWithdrawalDate(address _owner, uint256 _newDate)  public onlyOwner {
    payments[_owner] = (_newDate << 192) + uint192(payments[_owner]);
  }
  function asyncSend(address _dest) public payable onlyNutz {
    require(msg.value > 0);
    uint256 newValue = msg.value.add(uint192(payments[_dest]));
    uint256 newDate;
    if (isUnderLimit(msg.value)) {
      uint256 date = payments[_dest] >> 192;
      newDate = (date > now) ? date : now;
    } else {
      newDate = now.add(3 days);
    }
    spentToday = spentToday.add(msg.value);
    payments[_dest] = (newDate << 192) + uint192(newValue);
  }
  function withdraw() public whenNotPaused {
    address untrustedRecipient = msg.sender;
    uint256 amountWei = uint192(payments[untrustedRecipient]);
    require(amountWei != 0);
    require(now >= (payments[untrustedRecipient] >> 192));
    require(this.balance >= amountWei);
    payments[untrustedRecipient] = 0;
    assert(untrustedRecipient.call.gas(1000).value(amountWei)());
  }
  function isUnderLimit(uint amount) internal returns (bool) {
    if (now > lastDay.add(24 hours)) {
      lastDay = now;
      spentToday = 0;
    }
    if (spentToday + amount > dailyLimit || spentToday + amount < spentToday) {
      return false;
    }
    return true;
  }
}
