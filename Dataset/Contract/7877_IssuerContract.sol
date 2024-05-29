contract IssuerContract {
  using AddressExtension for address;
  event SetIssuer(address indexed _address);
  modifier onlyIssuer {
    require(issuer == msg.sender);
    _;
  }
  address public issuer;
  address public newIssuer;
  constructor(address _issuer) internal {
    issuer = _issuer;
  }
  function setIssuer(address _address) public onlyIssuer {
    newIssuer = _address;
  }
  function confirmSetIssuer() public {
    require(newIssuer == msg.sender);
    emit SetIssuer(issuer = newIssuer);
    delete newIssuer;
  }
}
