contract PolicyRegistry is Ownable, EmergencySafe, Upgradeable{
  event PolicyCreated(address at, address by);
  IXTPaymentContract public IXTPayment;
  mapping (address => address[]) private policiesByParticipant;
  address[] private policies;
  function PolicyRegistry(address paymentAddress) public {
    IXTPayment = IXTPaymentContract(paymentAddress);
  }
  function createContract(string _clientName, address _brokerEtherAddress, address _clientEtherAddress, string _enquiryId) public isNotPaused {
    Policy policy = new Policy(_clientName, _brokerEtherAddress, _clientEtherAddress, _enquiryId);
    policy.changeOwner(msg.sender);
    policiesByParticipant[_brokerEtherAddress].push(policy);
    if (_clientEtherAddress != _brokerEtherAddress) {
      policiesByParticipant[_clientEtherAddress].push(policy);
    }
    if (msg.sender != _clientEtherAddress && msg.sender != _brokerEtherAddress) {
      policiesByParticipant[msg.sender].push(policy);
    }
    policies.push(policy);
    IXTPayment.transferIXT(_clientEtherAddress, owner, "create_insurance");
    emit PolicyCreated(policy, msg.sender);
  }
  function getMyPolicies() public view returns (address[]) {
    return policiesByParticipant[msg.sender];
  }
  function getAllPolicies() public view ownerOnly returns (address[]){
    return policies;
  }
  function changePaymentContract(address contractAddress) public ownerOnly{
    IXTPayment = IXTPaymentContract(contractAddress);
  }
}
