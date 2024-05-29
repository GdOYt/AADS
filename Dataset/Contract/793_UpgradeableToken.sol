contract UpgradeableToken is StandardTokenExt {
  address public upgradeMaster;
  UpgradeAgent public upgradeAgent;
  uint256 public totalUpgraded;
  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}
  event Upgrade(address indexed _from, address indexed _to, uint256 _value);
  event UpgradeAgentSet(address agent);
  function UpgradeableToken(address _upgradeMaster) public {
    upgradeMaster = _upgradeMaster;
  }
  function upgrade(uint256 value) public {
      UpgradeState state = getUpgradeState();
      if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
        revert();
      }
      if (value == 0) revert();
      balances[msg.sender] = balances[msg.sender].sub(value);
      totalSupply_ = totalSupply_.sub(value);
      totalUpgraded = totalUpgraded.add(value);
      upgradeAgent.upgradeFrom(msg.sender, value);
      Upgrade(msg.sender, upgradeAgent, value);
  }
  function setUpgradeAgent(address agent) external {
      if(!canUpgrade()) {
        revert();
      }
      if (agent == 0x0) revert();
      if (msg.sender != upgradeMaster) revert();
      if (getUpgradeState() == UpgradeState.Upgrading) revert();
      upgradeAgent = UpgradeAgent(agent);
      if(!upgradeAgent.isUpgradeAgent()) revert();
      if (upgradeAgent.originalSupply() != totalSupply_) revert();
      UpgradeAgentSet(upgradeAgent);
  }
  function getUpgradeState() public constant returns(UpgradeState) {
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }
  function setUpgradeMaster(address master) public {
      if (master == 0x0) revert();
      if (msg.sender != upgradeMaster) revert();
      upgradeMaster = master;
  }
  function canUpgrade() public view returns(bool);
}
