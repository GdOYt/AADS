contract Ownable {
  address public owner;
  address public oldOwner;
  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  modifier onlyOldOwner() {
    require(msg.sender == oldOwner || msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    oldOwner = owner;
    owner = newOwner;
  }
  function backToOldOwner() onlyOldOwner public {
    require(oldOwner != address(0));
    owner = oldOwner;
  }
}
