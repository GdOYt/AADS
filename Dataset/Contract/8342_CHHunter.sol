contract CHHunter is CHGameBase {
  event UpgradeHunter(
    address indexed user,
    string attribute,
    uint256 to
  );
  struct Config {
    uint256 chicken;
    uint256 ethereum;
    uint256 max;
  }
  Config public typeA;
  Config public typeB;
  function upgradeStrength(uint256 _to) external payable {
    House storage _house = _houseOf(msg.sender);
    uint256 _from = _house.hunter.strength;
    require(typeA.max >= _to && _to > _from);
    _payForUpgrade(_from, _to, typeA);
    uint256 _increment = _house.hunter.dexterity.mul(2).add(8).mul(_to.square() - _from ** 2);
    _house.hunter.strength = _to;
    _house.huntingPower = _house.huntingPower.add(_increment);
    _house.offensePower = _house.offensePower.add(_increment);
    emit UpgradeHunter(msg.sender, "strength", _to);
  }
  function upgradeDexterity(uint256 _to) external payable {
    House storage _house = _houseOf(msg.sender);
    uint256 _from = _house.hunter.dexterity;
    require(typeB.max >= _to && _to > _from);
    _payForUpgrade(_from, _to, typeB);
    uint256 _increment = _house.hunter.strength.square().mul((_to - _from).mul(2));
    _house.hunter.dexterity = _to;
    _house.huntingPower = _house.huntingPower.add(_increment);
    _house.offensePower = _house.offensePower.add(_increment);
    emit UpgradeHunter(msg.sender, "dexterity", _to);
  }
  function upgradeConstitution(uint256 _to) external payable {
    House storage _house = _houseOf(msg.sender);
    uint256 _from = _house.hunter.constitution;
    require(typeA.max >= _to && _to > _from);
    _payForUpgrade(_from, _to, typeA);
    uint256 _increment = _house.hunter.resistance.mul(2).add(8).mul(_to.square() - _from ** 2);
    _house.hunter.constitution = _to;
    _house.defensePower = _house.defensePower.add(_increment);
    emit UpgradeHunter(msg.sender, "constitution", _to);
  }
  function upgradeResistance(uint256 _to) external payable {
    House storage _house = _houseOf(msg.sender);
    uint256 _from = _house.hunter.resistance;
    require(typeB.max >= _to && _to > _from);
    _payForUpgrade(_from, _to, typeB);
    uint256 _increment = _house.hunter.constitution.square().mul((_to - _from).mul(2));
    _house.hunter.resistance = _to;
    _house.defensePower = _house.defensePower.add(_increment);
    emit UpgradeHunter(msg.sender, "resistance", _to);
  }
  function _payForUpgrade(uint256 _from, uint256 _to, Config _type) internal {
    uint256 _chickenCost = _type.chicken.mul(_gapOfCubeSum(_from, _to));
    _payChicken(msg.sender, _chickenCost);
    uint256 _ethereumCost = _type.ethereum.mul(_gapOfSquareSum(_from, _to));
    _payEthereumAndDistribute(_ethereumCost);
  }
  function _gapOfSquareSum(uint256 _before, uint256 _after)
    internal
    pure
    returns (uint256)
  {
    return (_after * (_after - 1) * (2 * _after - 1) - _before * (_before - 1) * (2 * _before - 1)) / 6;
  }
  function _gapOfCubeSum(uint256 _before, uint256 _after)
    internal
    pure
    returns (uint256)
  {
    return ((_after * (_after - 1)) ** 2 - (_before * (_before - 1)) ** 2) >> 2;
  }
}
