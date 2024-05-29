contract Ownable {
  address public owner;
  function Ownable() public {
    owner = msg.sender;
  }
  function changeOwner(address newOwner) public ownerOnly {
    require(newOwner != address(0));
    owner = newOwner;
  }
  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }
}
