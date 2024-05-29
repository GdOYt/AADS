contract owned {
  address public owner;
  function owned() public { owner = msg.sender; }
  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }
  function changeOwner( address newowner ) public onlyOwner {
    owner = newowner;
  }
}
