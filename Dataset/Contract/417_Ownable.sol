contract Ownable {
  address public owner;
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "onlyOwner wrong");
    _;
  }
  function setOwner(address _owner) onlyOwner public {
    owner = _owner;
  }
}
