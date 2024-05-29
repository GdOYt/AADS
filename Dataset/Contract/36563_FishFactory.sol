contract FishFactory {
  event AccountCreated(address proxy);
  function create(address _owner, address _lockAddr) {
    address proxy = new FishProxy(_owner, _lockAddr);
    AccountCreated(proxy);
  }
}
