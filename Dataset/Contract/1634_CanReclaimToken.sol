contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }
}
