contract ReentrancyGuard {
  bool private rentrancy_lock = false;
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }
}
