contract ServiceVoucher is Authorizable, ERC20Like {
  uint256 public totalSupply;
  string public name;
  string public symbol;
  uint8 public constant decimals = 0;
  bool public constant isConsumable = true;
  constructor(
    FsTKAuthority _fstkAuthority,
    string _name,
    string _symbol,
    string _metadata
  )
    Authorizable(_fstkAuthority)
    ERC20Like(_metadata)
    public
  {
    name = _name;
    symbol = _symbol;
  }
  function mint(address to, uint256 value) public onlyFsTKAuthorized returns (bool) {
    totalSupply = totalSupply.add(value);
    accounts[to].balance += value;
    emit Transfer(address(0), to, value);
    return true;
  }
  function consume(address from, uint256 value) public onlyFsTKAuthorized returns (bool) {
    Account storage fromAccount = accounts[from];
    fromAccount.balance = fromAccount.balance.sub(value);
    totalSupply -= value;
    emit Consume(from, value, bytes32(0));
    emit Transfer(from, address(0), value);
  }
  function setMetadata(string infoUrl) public onlyFsTKAuthorized {
    setMetadata0(infoUrl);
  }
  function setLiquid(bool liquidity) public onlyFsTKAuthorized {
    setLiquid0(liquidity);
  }
  function setERC20ApproveChecking(bool approveChecking) public onlyFsTKAuthorized {
    super.setERC20ApproveChecking(approveChecking);
  }
  function setDelegate(bool delegate) public onlyFsTKAuthorized {
    super.setDelegate(delegate);
  }
  function setDirectDebit(bool directDebit) public onlyFsTKAuthorized {
    super.setDirectDebit(directDebit);
  }
  function transferToken(ERC20 erc20, address to, uint256 value) public onlyFsTKAuthorized {
    erc20.transfer(to, value);
  }
}
