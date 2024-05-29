contract HasNoEther is Ownable {
  function HasNoEther() public payable {
    require(msg.value == 0);
  }
  function() external {
  }
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}
