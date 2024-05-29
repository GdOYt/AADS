contract ReturnVestingRegistry is Ownable {
  mapping (address => address) public returnAddress;
  function record(address from, address to) onlyOwner public {
    require(from != 0);
    returnAddress[from] = to;
  }
}
