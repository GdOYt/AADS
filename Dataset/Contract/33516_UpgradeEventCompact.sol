contract UpgradeEventCompact {
  using SafeMath for uint;
  enum EventState { Verifying, Complete }
  EventState public state;
  address public nextController;
  address public oldController;
  address public council;
  address nextPullPayment;
  address storageAddr;
  address nutzAddr;
  address powerAddr;
  uint256 maxPower;
  uint256 downtime;
  uint256 purchasePrice;
  uint256 salePrice;
  function UpgradeEventCompact(address _oldController, address _nextController, address _nextPullPayment) {
    state = EventState.Verifying;
    nextController = _nextController;
    oldController = _oldController;
    nextPullPayment = _nextPullPayment;  
    council = msg.sender;
  }
  modifier isState(EventState _state) {
    require(state == _state);
    _;
  }
  function upgrade() isState(EventState.Verifying) {
    var old = Controller(oldController);
    old.pause();
    require(old.admins(1) == address(this));
    require(old.paused() == true);
    var next = Controller(nextController);
    require(next.admins(1) == address(this));
    require(next.paused() == true);
    storageAddr = old.storageAddr();
    nutzAddr = old.nutzAddr();
    powerAddr = old.powerAddr();
    maxPower = old.maxPower();
    downtime = old.downtime();
    purchasePrice = old.ceiling();
    salePrice = old.floor();
    uint newPowerPool = (old.outstandingPower()).mul(old.activeSupply().add(old.burnPool())).div(old.authorizedPower().sub(old.outstandingPower()));
    old.setContracts(powerAddr, nextPullPayment, nutzAddr, storageAddr);
    old.kill(nextController);
    Ownable(nutzAddr).transferOwnership(nextController);
    Ownable(powerAddr).transferOwnership(nextController);
    Storage(storageAddr).setUInt('Nutz', 'powerPool', newPowerPool);
    Ownable(storageAddr).transferOwnership(nextController);
    Ownable(nextPullPayment).transferOwnership(nextController);
    if (maxPower > 0) {
      next.setMaxPower(maxPower);
    }
    next.setDowntime(downtime);
    next.moveFloor(salePrice);
    next.moveCeiling(purchasePrice);
    next.unpause();
    next.removeAdmin(address(this));
    state = EventState.Complete;
  }
}
