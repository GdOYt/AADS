contract CHCommittee is CHAltar {
  event NewPet(
    uint256 id,
    uint256 huntingPower,
    uint256 offensePower,
    uint256 defense,
    uint256 chicken,
    uint256 ethereum,
    uint256 max
  );
  event ChangePet(
    uint256 id,
    uint256 chicken,
    uint256 ethereum,
    uint256 max
  );
  event NewItem(
    uint256 id,
    uint256 huntingMultiplier,
    uint256 offenseMultiplier,
    uint256 defenseMultiplier,
    uint256 ethereum
  );
  event SetDepot(uint256 ethereum, uint256 max);
  event SetConfiguration(
    uint256 chickenA,
    uint256 ethereumA,
    uint256 maxA,
    uint256 chickenB,
    uint256 ethereumB,
    uint256 maxB
  );
  event SetDistribution(
    uint256 dividendRate,
    uint256 altarCut,
    uint256 storeCut,
    uint256 devCut
  );
  event SetCooldownTime(uint256 cooldownTime);
  event SetNameAndSymbol(string name, string symbol);
  event SetDeveloper(address developer);
  event SetCommittee(address committee);
  address public committee;
  address public developer;
  function callFor(address _to, uint256 _value, uint256 _gas, bytes _code)
    external
    payable
    onlyCommittee
    returns (bool)
  {
    return _to.call.value(_value).gas(_gas)(_code);
  }
  function addPet(
    uint256 _huntingPower,
    uint256 _offensePower,
    uint256 _defense,
    uint256 _chicken,
    uint256 _ethereum,
    uint256 _max
  )
    public
    onlyCommittee
  {
    require(_max > 0);
    require(_max == uint256(uint32(_max)));
    uint256 _newLength = pets.push(
      Pet(_huntingPower, _offensePower, _defense, _chicken, _ethereum, _max)
    );
    emit NewPet(
      _newLength - 1,
      _huntingPower,
      _offensePower,
      _defense,
      _chicken,
      _ethereum,
      _max
    );
  }
  function changePet(
    uint256 _id,
    uint256 _chicken,
    uint256 _ethereum,
    uint256 _max
  )
    public
    onlyCommittee
  {
    require(_id < pets.length);
    Pet storage _pet = pets[_id];
    require(_max >= _pet.max && _max == uint256(uint32(_max)));
    _pet.chicken = _chicken;
    _pet.ethereum = _ethereum;
    _pet.max = _max;
    emit ChangePet(_id, _chicken, _ethereum, _max);
  }
  function addItem(
    uint256 _huntingMultiplier,
    uint256 _offenseMultiplier,
    uint256 _defenseMultiplier,
    uint256 _price
  )
    public
    onlyCommittee
  {
    uint256 _cap = 1 << 16;
    require(
      _huntingMultiplier < _cap &&
      _offenseMultiplier < _cap &&
      _defenseMultiplier < _cap
    );
    saveChickenOf(committee);
    House storage _house = _houseOf(committee);
    _house.huntingMultiplier = _house.huntingMultiplier.add(_huntingMultiplier);
    _house.offenseMultiplier = _house.offenseMultiplier.add(_offenseMultiplier);
    _house.defenseMultiplier = _house.defenseMultiplier.add(_defenseMultiplier);
    uint256 _newLength = items.push(
      Item(
        committee,
        _huntingMultiplier,
        _offenseMultiplier,
        _defenseMultiplier,
        _price
      )
    );
    emit NewItem(
      _newLength - 1,
      _huntingMultiplier,
      _offenseMultiplier,
      _defenseMultiplier,
      _price
    );
  }
  function setDepot(uint256 _price, uint256 _max) public onlyCommittee {
    require(_max >= depot.max);
    depot.ethereum = _price;
    depot.max = _max;
    emit SetDepot(_price, _max);
  }
  function setConfiguration(
    uint256 _chickenA,
    uint256 _ethereumA,
    uint256 _maxA,
    uint256 _chickenB,
    uint256 _ethereumB,
    uint256 _maxB
  )
    public
    onlyCommittee
  {
    require(_maxA >= typeA.max && (_maxA == uint256(uint32(_maxA))));
    require(_maxB >= typeB.max && (_maxB == uint256(uint32(_maxB))));
    typeA.chicken = _chickenA;
    typeA.ethereum = _ethereumA;
    typeA.max = _maxA;
    typeB.chicken = _chickenB;
    typeB.ethereum = _ethereumB;
    typeB.max = _maxB;
    emit SetConfiguration(_chickenA, _ethereumA, _maxA, _chickenB, _ethereumB, _maxB);
  }
  function setDistribution(
    uint256 _dividendRate,
    uint256 _altarCut,
    uint256 _storeCut,
    uint256 _devCut
  )
    public
    onlyCommittee
  {
    require(_storeCut > 0);
    require(
      _dividendRate.add(_altarCut).add(_storeCut).add(_devCut) == 100
    );
    dividendRate = _dividendRate;
    altarCut = _altarCut;
    store.cut = _storeCut;
    devCut = _devCut;
    emit SetDistribution(_dividendRate, _altarCut, _storeCut, _devCut);
  }
  function setCooldownTime(uint256 _cooldownTime) public onlyCommittee {
    cooldownTime = _cooldownTime;
    emit SetCooldownTime(_cooldownTime);
  }
  function setNameAndSymbol(string _name, string _symbol)
    public
    onlyCommittee
  {
    name = _name;
    symbol = _symbol;
    emit SetNameAndSymbol(_name, _symbol);
  }
  function setDeveloper(address _developer) public onlyCommittee {
    require(_developer != address(0));
    withdrawDevFee();
    developer = _developer;
    emit SetDeveloper(_developer);
  }
  function setCommittee(address _committee) public onlyCommittee {
    require(_committee != address(0));
    committee = _committee;
    emit SetCommittee(_committee);
  }
  function withdrawDevFee() public {
    ethereumBalance[developer] = ethereumBalance[developer].add(devFee);
    delete devFee;
  }
  modifier onlyCommittee {
    require(msg.sender == committee);
    _;
  }
}
