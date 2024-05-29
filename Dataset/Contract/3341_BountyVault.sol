contract BountyVault is Ownable {
  using SafeMath for uint256;
  DTXToken public tokenContract;
  uint256 public allocatedTotal;
  mapping(address => uint256) public balances;
  constructor(
    address _tokenAddress
  ) public {
    tokenContract = DTXToken(_tokenAddress);
  }
  function withdrawTokens() public {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "You have no tokens left");
    balances[msg.sender] = 0;
    require(tokenContract.transfer(msg.sender, amount), "Token transfer failed");
  }
  function allocateTokens(address[] _recipients, uint256[] _amounts) public onlyOwner {
    for (uint256 i = 0; i < _recipients.length; i++) {
      balances[_recipients[i]] = balances[_recipients[i]].add(_amounts[i]);
      allocatedTotal = allocatedTotal.add(_amounts[i]);
    }
  }
}
