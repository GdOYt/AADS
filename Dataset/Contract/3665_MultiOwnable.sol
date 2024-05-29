contract MultiOwnable {
  bool public isLocked;
  address public owner1;
  address public owner2;
  mapping(bytes32 => PendingState) public m_pending;
  struct PendingState {
    bool confirmation1;
    bool confirmation2;
    uint exists;  
  }
  event Confirmation(address owner, bytes32 operation);
  event Revoke(address owner, bytes32 operation);
  event ConfirmationNeeded(bytes32 operation, address from, uint value, address to);
  modifier onlyOwner {
    require(isOwner(msg.sender));
    _;
  }
  modifier onlyManyOwners(bytes32 _operation) {
    if (confirmAndCheck(_operation))
      _;
  }
  modifier onlyIfUnlocked {
    require(!isLocked);
    _;
  }
  constructor(address _owner1, address _owner2) public {
    require(_owner1 != address(0));
    require(_owner2 != address(0));
    owner1 = _owner1;
    owner2 = _owner2;
    isLocked = true;
  }
  function unlock() public onlyOwner {
    isLocked = false;
  }
  function revoke(bytes32 _operation) external onlyOwner {
    emit Revoke(msg.sender, _operation);
    delete m_pending[_operation];
  }
  function isOwner(address _addr) public view returns (bool) {
    return _addr == owner1 || _addr == owner2;
  }
  function hasConfirmed(bytes32 _operation, address _owner)
    constant public onlyOwner
    returns (bool) {
    if (_owner == owner1) {
      return m_pending[_operation].confirmation1;
    }
    if (_owner == owner2) {
      return m_pending[_operation].confirmation2;
    }
  }
  function confirmAndCheck(bytes32 _operation)
    internal onlyOwner
    returns (bool) {
    if (m_pending[_operation].exists == 0) {
      if (msg.sender == owner1) { m_pending[_operation].confirmation1 = true; }
      if (msg.sender == owner2) { m_pending[_operation].confirmation2 = true; }
      m_pending[_operation].exists = 1;
      return false;
    }
    if (msg.sender == owner1 && m_pending[_operation].confirmation1 == true) {
      return false;
    }
    if (msg.sender == owner2 && m_pending[_operation].confirmation2 == true) {
      return false;
    }
    if (msg.sender == owner1) {
      m_pending[_operation].confirmation1 = true;
    }
    if (msg.sender == owner2) {
      m_pending[_operation].confirmation2 = true;
    }
    return m_pending[_operation].confirmation1 && m_pending[_operation].confirmation2;
  }
}
