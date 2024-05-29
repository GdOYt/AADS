contract DetherBank is ERC223ReceivingContract, Ownable, SafeMath, DateTime {
  using BytesLib for bytes;
  event receiveDth(address _from, uint amount);
  event receiveEth(address _from, uint amount);
  event sendDth(address _from, uint amount);
  event sendEth(address _from, uint amount);
  mapping(address => uint) public dthShopBalance;
  mapping(address => uint) public dthTellerBalance;
  mapping(address => uint) public ethShopBalance;
  mapping(address => uint) public ethTellerBalance;
  mapping(address => mapping(uint16 => mapping(uint16 => mapping(uint16 => uint256)))) ethSellsUserToday;
  ERC223Basic public dth;
  bool public isInit = false;
  function setDth (address _dth) external onlyOwner {
    require(!isInit);
    dth = ERC223Basic(_dth);
    isInit = true;
  }
  function withdrawDthTeller(address _receiver) external onlyOwner {
    require(dthTellerBalance[_receiver] > 0);
    uint tosend = dthTellerBalance[_receiver];
    dthTellerBalance[_receiver] = 0;
    require(dth.transfer(_receiver, tosend));
  }
  function withdrawDthShop(address _receiver) external onlyOwner  {
    require(dthShopBalance[_receiver] > 0);
    uint tosend = dthShopBalance[_receiver];
    dthShopBalance[_receiver] = 0;
    require(dth.transfer(_receiver, tosend));
  }
  function withdrawDthShopAdmin(address _from, address _receiver) external onlyOwner  {
    require(dthShopBalance[_from]  > 0);
    uint tosend = dthShopBalance[_from];
    dthShopBalance[_from] = 0;
    require(dth.transfer(_receiver, tosend));
  }
  function addTokenShop(address _from, uint _value) external onlyOwner {
    dthShopBalance[_from] = SafeMath.add(dthShopBalance[_from], _value);
  }
  function addTokenTeller(address _from, uint _value) external onlyOwner{
    dthTellerBalance[_from] = SafeMath.add(dthTellerBalance[_from], _value);
  }
  function addEthTeller(address _from, uint _value) external payable onlyOwner returns (bool) {
    ethTellerBalance[_from] = SafeMath.add(ethTellerBalance[_from] ,_value);
    return true;
  }
  function getDateInfo(uint timestamp) internal view returns(_DateTime) {
    _DateTime memory date = parseTimestamp(timestamp);
    return date;
  }
  function withdrawEth(address _from, address _to, uint _amount) external onlyOwner {
    require(ethTellerBalance[_from] >= _amount);
    ethTellerBalance[_from] = SafeMath.sub(ethTellerBalance[_from], _amount);
    uint256 weiSoldToday = getWeiSoldToday(_from);
    _DateTime memory date = getDateInfo(block.timestamp);
    ethSellsUserToday[_from][date.day][date.month][date.year] = SafeMath.add(weiSoldToday, _amount);
    _to.transfer(_amount);
  }
  function refundEth(address _from) external onlyOwner {
    uint toSend = ethTellerBalance[_from];
    if (toSend > 0) {
      ethTellerBalance[_from] = 0;
      _from.transfer(toSend);
    }
  }
  function getDthTeller(address _user) public view returns (uint) {
    return dthTellerBalance[_user];
  }
  function getDthShop(address _user) public view returns (uint) {
    return dthShopBalance[_user];
  }
  function getEthBalTeller(address _user) public view returns (uint) {
    return ethTellerBalance[_user];
  }
  function getWeiSoldToday(address _user) public view returns (uint256 weiSoldToday) {
    _DateTime memory date = getDateInfo(block.timestamp);
    weiSoldToday = ethSellsUserToday[_user][date.day][date.month][date.year];
  }
  function tokenFallback(address _from, uint _value, bytes _data) {
    require(msg.sender == address(dth));
  }
}
