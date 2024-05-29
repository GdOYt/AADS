contract mortal is owned {
  function close() onlyOwner public {
    selfdestruct(owner);
  }
}
