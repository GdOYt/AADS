contract Claimable is Ownable {
  address public pendingOwner;
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}
