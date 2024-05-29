contract ReentrancyGuard {
  bool private reentrancyLock = false;
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }
}
