contract OceanTokenTransferManager is Ownable, Whitelist {
  function canTransferFrom(address _from, address _to) public constant returns (bool success) {
    if (whitelist[_from] == true || whitelist[_to] == true) {
      return true;
    } else {
      return false;
    }
  }
}
