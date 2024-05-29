contract UpgradableStorage is Ownable {
  address internal _implementation;
  event NewImplementation(address implementation);
  function implementation() public view returns (address) {
    return _implementation;
  }
}
