contract StorageConsumer is StorageStateful {
  function StorageConsumer(address _storageAddress) public {
    require(_storageAddress != address(0));
    keyValueStorage = KeyValueStorage(_storageAddress);
  }
}
