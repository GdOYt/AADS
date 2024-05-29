contract ReserveToken is StandardToken, SafeMath {
  address public minter;
  function ReserveToken() public {
    minter = msg.sender;
  }
  function create(address account, uint amount) public {
    if (msg.sender != minter) revert();
    balances[account] = safeAdd(balances[account], amount);
    totalSupply = safeAdd(totalSupply, amount);
  }
  function destroy(address account, uint amount) public {
    if (msg.sender != minter) revert();
    if (balances[account] < amount) revert();
    balances[account] = safeSub(balances[account], amount);
    totalSupply = safeSub(totalSupply, amount);
  }
}
