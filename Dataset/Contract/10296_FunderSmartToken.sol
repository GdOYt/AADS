contract FunderSmartToken is Authorizable, ERC20Like {
  string public constant name = "Funder Smart Token";
  string public constant symbol = "FST";
  uint256 public constant totalSupply = 330000000 ether;
  uint8 public constant decimals = 18;
  constructor(
    FsTKAuthority _fstkAuthority,
    string _metadata,
    address coldWallet,
    FsTKAllocation allocation
  )
    Authorizable(_fstkAuthority)
    ERC20Like(_metadata)
    public
  {
    uint256 vestedAmount = totalSupply / 12;
    accounts[allocation].balance = vestedAmount;
    emit Transfer(address(0), allocation, vestedAmount);
    allocation.initialize(vestedAmount);
    uint256 releaseAmount = totalSupply - vestedAmount;
    accounts[coldWallet].balance = releaseAmount;
    emit Transfer(address(0), coldWallet, releaseAmount);
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
