contract Ownable {
  address internal contractOwner;
  constructor () internal {
    if(contractOwner == address(0)){
      contractOwner = msg.sender;
    }
  }
  modifier onlyOwner() {
    require(msg.sender == contractOwner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    contractOwner = newOwner;
  }
}
