contract OwnableStorage {
  address public owner;
  function OwnableStorage() internal {
    owner = msg.sender;
  }
}
