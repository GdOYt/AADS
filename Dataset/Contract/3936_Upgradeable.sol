contract Upgradeable is Ownable{
  address public lastContract;
  address public nextContract;
  bool public isOldVersion;
  bool public allowedToUpgrade;
  function Upgradeable() public {
    allowedToUpgrade = true;
  }
  function upgradeTo(Upgradeable newContract) public ownerOnly{
    require(allowedToUpgrade && !isOldVersion);
    nextContract = newContract;
    isOldVersion = true;
    newContract.confirmUpgrade();   
  }
  function confirmUpgrade() public {
    require(lastContract == address(0));
    lastContract = msg.sender;
  }
}
