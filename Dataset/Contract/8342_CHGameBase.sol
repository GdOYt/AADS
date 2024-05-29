contract CHGameBase is CHStock {
  struct House {
    Hunter hunter;
    uint256 huntingPower;
    uint256 offensePower;
    uint256 defensePower;
    uint256 huntingMultiplier;
    uint256 offenseMultiplier;
    uint256 defenseMultiplier;
    uint256 depots;
    uint256[] pets;
  }
  struct Hunter {
    uint256 strength;
    uint256 dexterity;
    uint256 constitution;
    uint256 resistance;
  }
  struct Store {
    address owner;
    uint256 cut;
    uint256 cost;
    uint256 balance;
  }
  Store public store;
  uint256 public devCut;
  uint256 public devFee;
  uint256 public altarCut;
  uint256 public altarFund;
  uint256 public dividendRate;
  uint256 public totalChicken;
  address public chickenTokenDelegator;
  mapping (address => uint256) public lastSaveTime;
  mapping (address => uint256) public savedChickenOf;
  mapping (address => House) internal houses;
  function saveChickenOf(address _user) public returns (uint256) {
    uint256 _unclaimedChicken = _unclaimedChickenOf(_user);
    totalChicken = totalChicken.add(_unclaimedChicken);
    uint256 _chicken = savedChickenOf[_user].add(_unclaimedChicken);
    savedChickenOf[_user] = _chicken;
    lastSaveTime[_user] = block.timestamp;
    return _chicken;
  }
  function transferChickenFrom(address _from, address _to, uint256 _value)
    public
    returns (bool)
  {
    require(msg.sender == chickenTokenDelegator);
    require(saveChickenOf(_from) >= _value);
    savedChickenOf[_from] = savedChickenOf[_from] - _value;
    savedChickenOf[_to] = savedChickenOf[_to].add(_value);
    return true;
  }
  function chickenOf(address _user) public view returns (uint256) {
    return savedChickenOf[_user].add(_unclaimedChickenOf(_user));
  }
  function _payChicken(address _user, uint256 _chicken) internal {
    uint256 _unclaimedChicken = _unclaimedChickenOf(_user);
    uint256 _extraChicken;
    if (_chicken > _unclaimedChicken) {
      _extraChicken = _chicken - _unclaimedChicken;
      require(savedChickenOf[_user] >= _extraChicken);
      savedChickenOf[_user] -= _extraChicken;
      totalChicken -= _extraChicken;
    } else {
      _extraChicken = _unclaimedChicken - _chicken;
      totalChicken = totalChicken.add(_extraChicken);
      savedChickenOf[_user] += _extraChicken;
    }
    lastSaveTime[_user] = block.timestamp;
  }
  function _payEthereumAndDistribute(uint256 _cost) internal {
    require(_cost * 100 / 100 == _cost);
    _payEthereum(_cost);
    uint256 _toShareholders = _cost * dividendRate / 100;
    uint256 _toAltar = _cost * altarCut / 100;
    uint256 _toStore = _cost * store.cut / 100;
    devFee = devFee.add(_cost - _toShareholders - _toAltar - _toStore);
    _giveShares(msg.sender, _toShareholders);
    altarFund = altarFund.add(_toAltar);
    store.balance = store.balance.add(_toStore);
  }
  function _payEthereum(uint256 _cost) internal {
    uint256 _extra;
    if (_cost > msg.value) {
      _extra = _cost - msg.value;
      require(ethereumBalance[msg.sender] >= _extra);
      ethereumBalance[msg.sender] -= _extra;
    } else {
      _extra = msg.value - _cost;
      ethereumBalance[msg.sender] = ethereumBalance[msg.sender].add(_extra);
    }
  }
  function _unclaimedChickenOf(address _user) internal view returns (uint256) {
    uint256 _timestamp = lastSaveTime[_user];
    if (_timestamp > 0 && _timestamp < block.timestamp) {
      return houses[_user].huntingPower.mul(
        houses[_user].huntingMultiplier
      ).mul(block.timestamp - _timestamp) / 100;
    } else {
      return 0;
    }
  }
  function _houseOf(address _user)
    internal
    view
    returns (House storage _house)
  {
    _house = houses[_user];
    require(_house.depots > 0);
  }
}
