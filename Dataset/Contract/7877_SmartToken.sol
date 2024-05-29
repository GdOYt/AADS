contract SmartToken is Authorizable, IssuerContract, ERC20Like {
  string public name;
  string public symbol;
  uint256 public totalSupply;
  uint8 public constant decimals = 18;
  constructor(
    address _issuer,
    FsTKAuthority _fstkAuthority,
    string _name,
    string _symbol,
    uint256 _totalSupply,
    string _metadata
  )
    Authorizable(_fstkAuthority)
    IssuerContract(_issuer)
    ERC20Like(_metadata)
    public
  {
    name = _name;
    symbol = _symbol;
    totalSupply = _totalSupply;
    accounts[_issuer].balance = _totalSupply;
    emit Transfer(address(0), _issuer, _totalSupply);
  }
  function setERC20ApproveChecking(bool approveChecking) public onlyIssuer {
    super.setERC20ApproveChecking(approveChecking);
  }
  function setDelegate(bool delegate) public onlyIssuer {
    super.setDelegate(delegate);
  }
  function setDirectDebit(bool directDebit) public onlyIssuer {
    super.setDirectDebit(directDebit);
  }
  function setMetadata(
    string infoUrl,
    uint256 approveTime,
    bytes approveToken
  )
    public
    onlyIssuer
    onlyFsTKApproved(keccak256(abi.encodePacked(approveTime, this, msg.sig, infoUrl)), approveTime, approveToken)
  {
    setMetadata0(infoUrl);
  }
  function setLiquid(
    bool liquidity,
    uint256 approveTime,
    bytes approveToken
  )
    public
    onlyIssuer
    onlyFsTKApproved(keccak256(abi.encodePacked(approveTime, this, msg.sig, liquidity)), approveTime, approveToken)
  {
    setLiquid0(liquidity);
  }
}
