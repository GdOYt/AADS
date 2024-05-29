contract CHArena is CHHouse {
  event Attack(
    address indexed attacker,
    address indexed defender,
    uint256 booty
  );
  mapping(address => uint256) public attackCooldown;
  uint256 public cooldownTime;
  function attack(address _target) external {
    require(attackCooldown[msg.sender] < block.timestamp);
    House storage _attacker = houses[msg.sender];
    House storage _defender = houses[_target];
    if (_attacker.offensePower.mul(_attacker.offenseMultiplier)
        > _defender.defensePower.mul(_defender.defenseMultiplier)) {
      uint256 _chicken = saveChickenOf(_target);
      _chicken = _defender.depots > 0 ? _chicken / _defender.depots : _chicken;
      savedChickenOf[_target] = savedChickenOf[_target] - _chicken;
      savedChickenOf[msg.sender] = savedChickenOf[msg.sender].add(_chicken);
      attackCooldown[msg.sender] = block.timestamp + cooldownTime;
      emit Attack(msg.sender, _target, _chicken);
    }
  }
}
