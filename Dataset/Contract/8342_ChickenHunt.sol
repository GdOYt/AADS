contract ChickenHunt is CHCommittee {
  event Join(address user);
  constructor() public {
    committee = msg.sender;
    developer = msg.sender;
  }
  function init(address _chickenTokenDelegator) external onlyCommittee {
    require(chickenTokenDelegator == address(0));
    chickenTokenDelegator = _chickenTokenDelegator;
    genesis = 1525791600;
    join();
    store.owner = msg.sender;
    store.cost = 0.1 ether;
    setConfiguration(100, 0.00001 ether, 99, 100000, 0.001 ether, 9);
    setDistribution(20, 75, 1, 4);
    setCooldownTime(600);
    setDepot(0.05 ether, 9);
    addItem(5, 5, 0, 0.01 ether);
    addItem(0, 0, 5, 0.01 ether);
    addPet(1000, 0, 0, 100000, 0.01 ether, 9);
    addPet(0, 1000, 0, 100000, 0.01 ether, 9);
    addPet(0, 0, 1000, 202500, 0.01 ether, 9);
  }
  function withdraw() external {
    uint256 _ethereum = ethereumBalance[msg.sender];
    delete ethereumBalance[msg.sender];
    msg.sender.transfer(_ethereum);
  }
  function join() public {
    House storage _house = houses[msg.sender];
    require(_house.depots == 0);
    _house.hunter = Hunter(1, 1, 1, 1);
    _house.depots = 1;
    _house.huntingPower = 10;
    _house.offensePower = 10;
    _house.defensePower = 110;
    _house.huntingMultiplier = 10;
    _house.offenseMultiplier = 10;
    _house.defenseMultiplier = 10;
    lastSaveTime[msg.sender] = block.timestamp;
    emit Join(msg.sender);
  }
  function hunterOf(address _user)
    public
    view
    returns (
      uint256 _strength,
      uint256 _dexterity,
      uint256 _constitution,
      uint256 _resistance
    )
  {
    Hunter memory _hunter = houses[_user].hunter;
    return (
      _hunter.strength,
      _hunter.dexterity,
      _hunter.constitution,
      _hunter.resistance
    );
  }
  function detailsOf(address _user)
    public
    view
    returns (
      uint256[2] _hunting,
      uint256[2] _offense,
      uint256[2] _defense,
      uint256[4] _hunter,
      uint256[] _pets,
      uint256 _depots,
      uint256 _savedChicken,
      uint256 _lastSaveTime,
      uint256 _cooldown
    )
  {
    House memory _house = houses[_user];
    _hunting = [_house.huntingPower, _house.huntingMultiplier];
    _offense = [_house.offensePower, _house.offenseMultiplier];
    _defense = [_house.defensePower, _house.defenseMultiplier];
    _hunter = [
      _house.hunter.strength,
      _house.hunter.dexterity,
      _house.hunter.constitution,
      _house.hunter.resistance
    ];
    _pets = _house.pets;
    _depots = _house.depots;
    _savedChicken = savedChickenOf[_user];
    _lastSaveTime = lastSaveTime[_user];
    _cooldown = attackCooldown[_user];
  }
}
