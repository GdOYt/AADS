contract Ownable {
  address public owner;
  address public newOwner;
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  constructor() public {
    owner = msg.sender;
  }
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
  event OwnershipTransferred(address oldOwner, address newOwner);
}
