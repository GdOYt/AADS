contract Authorizable {
  event SetFsTKAuthority(FsTKAuthority indexed _address);
  modifier onlyFsTKAuthorized {
    require(fstkAuthority.isAuthorized(msg.sender, this, msg.data));
    _;
  }
  modifier onlyFsTKApproved(bytes32 hash, uint256 approveTime, bytes approveToken) {
    require(fstkAuthority.isApproved(hash, approveTime, approveToken));
    _;
  }
  FsTKAuthority internal fstkAuthority;
  constructor(FsTKAuthority _fstkAuthority) internal {
    fstkAuthority = _fstkAuthority;
  }
  function setFsTKAuthority(FsTKAuthority _fstkAuthority) public onlyFsTKAuthorized {
    require(_fstkAuthority.validate() == _fstkAuthority.validate.selector);
    emit SetFsTKAuthority(fstkAuthority = _fstkAuthority);
  }
}
