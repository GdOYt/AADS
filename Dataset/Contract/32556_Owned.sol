contract Owned {
  address public owner = msg.sender;
  function transferOwner(address _newOwner) onlyOwner public returns (bool) {
    owner = _newOwner;
    return true;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
}
