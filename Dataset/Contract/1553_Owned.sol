contract Owned {
  address public owner;
  address public newOwner;
  event OwnershipTransferProposed(address indexed _from, address indexed _to);
  event OwnershipTransferConfirmed(address indexed _from, address indexed _to);
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  constructor() public{
    owner = msg.sender;
  }
  function transferOwnership(address _newOwner) onlyOwner public{
    require(_newOwner != owner);
    emit OwnershipTransferProposed(owner, _newOwner);
    newOwner = _newOwner;
  }
  function confirmOwnership() public{
    assert(msg.sender == newOwner);
    emit OwnershipTransferConfirmed(owner, newOwner);
    owner = newOwner;
  }
}
