contract Owned {
  address public owner;
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner returns (address account) {
    owner = newOwner;
    return owner;
  }
}
