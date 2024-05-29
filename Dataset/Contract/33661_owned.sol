contract owned {
  address public owner;
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function owned() public{
    owner = msg.sender;
  }
  function changeOwner(address newOwner) onlyOwner public{
    owner = newOwner;
  }
}
