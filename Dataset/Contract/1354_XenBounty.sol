contract XenBounty is TimelockedToken, HasNoEther {
  string public constant name = "Xen Bounty";
  string public constant symbol = "XENB";
  uint8 public constant decimals = 18;
  address public whitelisted;
  uint256 public constant INITIAL_SUPPLY = 50000000 * (10 ** uint256(decimals));
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Basic(tokenAddress).transfer(owner, tokens);
  }
}
