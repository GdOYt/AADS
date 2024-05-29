contract HasNoEther is Ownable {
  constructor() public payable {
    require(msg.value == 0);
  }
  function() external {
  }
  function reclaimEther() external onlyOwner {
    assert(owner.send(address(this).balance));
  }
}
