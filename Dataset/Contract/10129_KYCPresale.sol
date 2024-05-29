contract KYCPresale is CrowdsaleBase, KYCPayloadDeserializer {
  uint256 public saleWeiCap;
  address public signerAddress;
  event SignerChanged(address signer);
  event Prepurchased(address investor, uint weiAmount, uint tokenAmount, uint128 customerId, uint256 pricingInfo);
  event CapUpdated(uint256 newCap);
  function KYCPresale(address _multisigWallet, uint _start, uint _end, uint _saleWeiCap) CrowdsaleBase(FractionalERC20(address(1)), PricingStrategy(address(0)), _multisigWallet, _start, _end, 0) {
    saleWeiCap = _saleWeiCap;
  }
  function buyWithKYCData(bytes dataframe, uint8 v, bytes32 r, bytes32 s) public payable returns(uint tokenAmount) {
    require(!halted);
    bytes32 hash = sha256(dataframe);
    var (whitelistedAddress, customerId, minETH, maxETH, pricingInfo) = getKYCPayload(dataframe);
    uint multiplier = 10 ** 18;
    address receiver = msg.sender;
    uint weiAmount = msg.value;
    require(ecrecover(hash, v, r, s) == signerAddress);
    if(getState() == State.PreFunding) {
      require(earlyParticipantWhitelist[receiver]);
    } else if(getState() == State.Funding) {
    } else {
      revert();
    }
    if(investedAmountOf[receiver] == 0) {
       investorCount++;
    }
    investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);
    weiRaised = weiRaised.plus(weiAmount);
    require(!isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold));
    require(investedAmountOf[msg.sender] >= minETH * multiplier / 10000);
    require(investedAmountOf[msg.sender] <= maxETH * multiplier / 10000);
    require(multisigWallet.send(weiAmount));
    Prepurchased(receiver, weiAmount, tokenAmount, customerId, pricingInfo);
    return 0;  
  }
  function setSignerAddress(address _signerAddress) onlyOwner {
    signerAddress = _signerAddress;
    SignerChanged(signerAddress);
  }
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    if(weiRaisedTotal > saleWeiCap) {
      return true;
    } else {
      return false;
    }
  }
  function isCrowdsaleFull() public constant returns (bool) {
    return weiRaised >= saleWeiCap;
  }
  function setWeiCap(uint newCap) public onlyOwner {
    saleWeiCap = newCap;
    CapUpdated(newCap);
  }
  function assignTokens(address receiver, uint tokenAmount) internal {
    revert();
  }
  function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {
  }
  function getState() public constant returns (State) {
    if (block.timestamp < startsAt) {
      return State.PreFunding;
    } else {
      return State.Funding;
    }
  }
}
