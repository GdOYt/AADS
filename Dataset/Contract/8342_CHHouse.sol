contract CHHouse is CHHunter {
  event UpgradePet(
    address indexed user,
    uint256 id,
    uint256 to
  );
  event UpgradeDepot(
    address indexed user,
    uint256 to
  );
  event BuyItem(
    address indexed from,
    address indexed to,
    uint256 indexed id,
    uint256 cost
  );
  event BuyStore(
    address indexed from,
    address indexed to,
    uint256 cost
  );
  struct Pet {
    uint256 huntingPower;
    uint256 offensePower;
    uint256 defensePower;
    uint256 chicken;
    uint256 ethereum;
    uint256 max;
  }
  struct Item {
    address owner;
    uint256 huntingMultiplier;
    uint256 offenseMultiplier;
    uint256 defenseMultiplier;
    uint256 cost;
  }
  struct Depot {
    uint256 ethereum;
    uint256 max;
  }
  uint256 public constant INCREMENT_RATE = 12;  
  Depot public depot;
  Pet[] public pets;
  Item[] public items;
  function buyDepots(uint256 _amount) external payable {
    House storage _house = _houseOf(msg.sender);
    _house.depots = _house.depots.add(_amount);
    require(_house.depots <= depot.max);
    _payEthereumAndDistribute(_amount.mul(depot.ethereum));
    emit UpgradeDepot(msg.sender, _house.depots);
  }
  function buyPets(uint256 _id, uint256 _amount) external payable {
    require(_id < pets.length);
    Pet memory _pet = pets[_id];
    uint256 _chickenCost = _amount * _pet.chicken;
    _payChicken(msg.sender, _chickenCost);
    uint256 _ethereumCost = _amount * _pet.ethereum;
    _payEthereumAndDistribute(_ethereumCost);
    House storage _house = _houseOf(msg.sender);
    if (_house.pets.length < _id + 1) {
      _house.pets.length = _id + 1;
    }
    _house.pets[_id] = _house.pets[_id].add(_amount);
    require(_house.pets[_id] <= _pet.max);
    _house.huntingPower = _house.huntingPower.add(_pet.huntingPower * _amount);
    _house.offensePower = _house.offensePower.add(_pet.offensePower * _amount);
    _house.defensePower = _house.defensePower.add(_pet.defensePower * _amount);
    emit UpgradePet(msg.sender, _id, _house.pets[_id]);
  }
  function buyItem(uint256 _id) external payable {
    Item storage _item = items[_id];
    address _from = _item.owner;
    uint256 _price = _item.cost.mul(INCREMENT_RATE) / 10;
    _payEthereum(_price);
    saveChickenOf(_from);
    House storage _fromHouse = _houseOf(_from);
    _fromHouse.huntingMultiplier = _fromHouse.huntingMultiplier.sub(_item.huntingMultiplier);
    _fromHouse.offenseMultiplier = _fromHouse.offenseMultiplier.sub(_item.offenseMultiplier);
    _fromHouse.defenseMultiplier = _fromHouse.defenseMultiplier.sub(_item.defenseMultiplier);
    saveChickenOf(msg.sender);
    House storage _toHouse = _houseOf(msg.sender);
    _toHouse.huntingMultiplier = _toHouse.huntingMultiplier.add(_item.huntingMultiplier);
    _toHouse.offenseMultiplier = _toHouse.offenseMultiplier.add(_item.offenseMultiplier);
    _toHouse.defenseMultiplier = _toHouse.defenseMultiplier.add(_item.defenseMultiplier);
    uint256 _halfMargin = _price.sub(_item.cost) / 2;
    devFee = devFee.add(_halfMargin);
    ethereumBalance[_from] = ethereumBalance[_from].add(_price - _halfMargin);
    items[_id].cost = _price;
    items[_id].owner = msg.sender;
    emit BuyItem(_from, msg.sender, _id, _price);
  }
  function buyStore() external payable {
    address _from = store.owner;
    uint256 _price = store.cost.mul(INCREMENT_RATE) / 10;
    _payEthereum(_price);
    uint256 _halfMargin = (_price - store.cost) / 2;
    devFee = devFee.add(_halfMargin);
    ethereumBalance[_from] = ethereumBalance[_from].add(_price - _halfMargin).add(store.balance);
    store.cost = _price;
    store.owner = msg.sender;
    delete store.balance;
    emit BuyStore(_from, msg.sender, _price);
  }
  function withdrawStoreBalance() public {
    ethereumBalance[store.owner] = ethereumBalance[store.owner].add(store.balance);
    delete store.balance;
  }
}
