contract Ownable {
  address public owner;
  address public admin;
  function Ownable() public {
      owner = msg.sender;
  }
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }
  modifier onlyOwnerAdmin() {
      require(msg.sender == owner || msg.sender == admin);
      _;
  }
  function transferOwnership(address newOwner)public onlyOwner {
      if (newOwner != address(0)) {
        owner = newOwner;
      }
  }
  function setAdmin(address _admin)public onlyOwner {
      admin = _admin;
  }
}
