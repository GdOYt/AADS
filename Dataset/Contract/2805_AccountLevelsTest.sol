contract AccountLevelsTest is AccountLevels {
  mapping (address => uint) public accountLevels;
  function setAccountLevel(address user, uint level) {
    accountLevels[user] = level;
  }
  function accountLevel(address user) constant returns(uint) {
    return accountLevels[user];
  }
}
