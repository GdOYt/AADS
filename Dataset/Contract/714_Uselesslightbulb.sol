contract Uselesslightbulb is Ownable {
  uint weiPrice = 1000000000000000;
  uint count = 0;
  function toggle() public payable {
    require(msg.value >= weiPrice);
    count++; 
  }
  function getCount() external view returns (uint) {
    return count;
  }
  function withdraw() onlyOwner public {
    owner.transfer(address(this).balance);
  }
}
