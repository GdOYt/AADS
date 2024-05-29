contract Arbitrator is Ownable {
  mapping(address => bool) private aribitratorWhitelist;
  address private primaryArbitrator;
  event ArbitratorAdded(address indexed newArbitrator);
  event ArbitratorRemoved(address indexed newArbitrator);
  event ChangePrimaryArbitratorWallet(address indexed newPrimaryWallet);
  constructor() public {
    primaryArbitrator = msg.sender;
  }
  modifier onlyArbitrator() {
    require(aribitratorWhitelist[msg.sender] == true || msg.sender == primaryArbitrator);
    _;
  }
  function changePrimaryArbitrator(address walletAddress) public onlyOwner {
    require(walletAddress != address(0));
    emit ChangePrimaryArbitratorWallet(walletAddress);
    primaryArbitrator = walletAddress;
  }
  function addArbitrator(address newArbitrator) public onlyOwner {
    require(newArbitrator != address(0));
    emit ArbitratorAdded(newArbitrator);
    aribitratorWhitelist[newArbitrator] = true;
  }
  function deleteArbitrator(address arbitrator) public onlyOwner {
    require(arbitrator != address(0));
    require(arbitrator != msg.sender);  
    emit ArbitratorRemoved(arbitrator);
    delete aribitratorWhitelist[arbitrator];
  }
  function isArbitrator(address arbitratorCheck) external view returns(bool) {
    return (aribitratorWhitelist[arbitratorCheck] || arbitratorCheck == primaryArbitrator);
  }
}
