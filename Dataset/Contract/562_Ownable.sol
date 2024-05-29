contract Ownable {
  address public owner;
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    emit OwnerChanged(owner, _newOwner);
    owner = _newOwner;
  }
  event OwnerChanged(address indexed previousOwner,address indexed newOwner);
}
