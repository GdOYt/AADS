contract FishProxy is SharkProxy {
  address lockAddr;
  function FishProxy(address _owner, address _lockAddr) {
    owner = _owner;
    lockAddr = _lockAddr;
  }
  function isLocked() constant returns (bool) {
    return lockAddr != 0x0;
  }
  function unlock(bytes32 _r, bytes32 _s, bytes32 _pl) {
    assert(lockAddr != 0x0);
    uint8 v;
    uint88 target;
    address newOwner;
    assembly {
        v := calldataload(37)
        target := calldataload(48)
        newOwner := calldataload(68)
    }
    assert(target == uint88(address(this)));
    assert(newOwner == msg.sender);
    assert(newOwner != owner);
    assert(ecrecover(sha3(uint8(0), target, newOwner), v, _r, _s) == lockAddr);
    owner = newOwner;
    lockAddr = 0x0;
  }
  function() payable {
    assert(lockAddr == address(0) || this.balance <= 1e17);
    Deposit(msg.sender, msg.value);
  }
}
