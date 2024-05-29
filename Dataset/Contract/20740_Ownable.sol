contract Ownable {
  address[] public owners;
  event OwnerAdded(address indexed authorizer, address indexed newOwner, uint256 index);
  event OwnerRemoved(address indexed authorizer, address indexed oldOwner);
  function Ownable() public {
    owners.push(msg.sender);
    OwnerAdded(0x0, msg.sender, 0);
  }
  modifier onlyOwner() {
    bool isOwner = false;
    for (uint256 i = 0; i < owners.length; i++) {
      if (msg.sender == owners[i]) {
        isOwner = true;
        break;
      }
    }
    require(isOwner);
    _;
  }
  function addOwner(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    uint256 i = owners.push(newOwner) - 1;
    OwnerAdded(msg.sender, newOwner, i);
  }
  function removeOwner(uint256 index) onlyOwner public {
    address owner = owners[index];
    owners[index] = owners[owners.length - 1];
    delete owners[owners.length - 1];
    OwnerRemoved(msg.sender, owner);
  }
  function ownersCount() constant public returns (uint256) {
    return owners.length;
  }
}
