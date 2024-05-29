contract Policy is Ownable, EmergencySafe, Upgradeable{
  struct InsuranceProduct {
    uint inceptionDate;
    string insuranceType;
  }
  struct PolicyInfo {
    uint blockNumber;
    uint numInsuranceProducts;
    string clientName;
    string ixlEnquiryId;
    string status;
  }
  InsuranceProduct[] public insuranceProducts;
  PolicyInfo public policyInfo;
  address private brokerEtherAddress;
  address private clientEtherAddress;
  mapping(address => bool) private cancellations;
  modifier participantOnly() {
    require(msg.sender == clientEtherAddress || msg.sender == brokerEtherAddress);
    _;
  }
  function Policy(string _clientName, address _brokerEtherAddress, address _clientEtherAddress, string _enquiryId) public {
    policyInfo = PolicyInfo({
      blockNumber: block.number,
      numInsuranceProducts: 0,
      clientName: _clientName,
      ixlEnquiryId: _enquiryId,
      status: 'In Force'
    });
    clientEtherAddress =  _clientEtherAddress;
    brokerEtherAddress =  _brokerEtherAddress;
    allowedToUpgrade = false;
  }
  function addInsuranceProduct (uint _inceptionDate, string _insuranceType) public ownerOnly isNotPaused {
    insuranceProducts.push(InsuranceProduct({
      inceptionDate: _inceptionDate,
      insuranceType: _insuranceType
    }));
    policyInfo.numInsuranceProducts++;
  }
  function revokeContract() public participantOnly {
    cancellations[msg.sender] = true;
    if (((cancellations[brokerEtherAddress] && (cancellations[clientEtherAddress] || cancellations[owner]))
        || (cancellations[clientEtherAddress] && cancellations[owner]))){
      policyInfo.status = "REVOKED";
      allowedToUpgrade = true;
    }
  }
}
