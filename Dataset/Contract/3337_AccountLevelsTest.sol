contract AccountLevelsTest is AccountLevels {
  mapping (address => uint) public accountLevels;
  function setAccountLevel(address user, uint level) public {
    accountLevels[user] = level;
  }
  function accountLevel(address user) constant public returns(uint) {
    return accountLevels[user];
  }
}
