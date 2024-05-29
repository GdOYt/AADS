contract ContractWeb is CanTransferTokens, CheckIfContract {
  mapping(string => contractInfo) internal contracts;
  event ContractAdded(string _name, address _referredTo);
  event ContractEdited(string _name, address _referredTo);
  event ContractMadePermanent(string _name);
  struct contractInfo {
    address contractAddress;
    bool isPermanent;
  }
  function getContractAddress(string _name) view public returns (address) {
    return contracts[_name].contractAddress;
  }
  function isContractPermanent(string _name) view public returns (bool) {
    return contracts[_name].isPermanent;
  }
  function setContract(string _name, address _address) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {
    require(isContract(_address));
    require(this != _address);
    require(contracts[_name].contractAddress != _address);
    require(contracts[_name].isPermanent == false);
    address oldAddress = contracts[_name].contractAddress;
    contracts[_name].contractAddress = _address;
    if(oldAddress == address(0x0)) {
      ContractAdded(_name, _address);
    } else {
      ContractEdited(_name, _address);
    }
    return true;
  }
  function makeContractPermanent(string _name) onlyOwner public returns (bool) {
    require(contracts[_name].contractAddress != address(0x0));
    require(contracts[_name].isPermanent == false);
    contracts[_name].isPermanent = true;
    ContractMadePermanent(_name);
    return true;
  }
  function tokenSetup(address _Tokens1st, address _Balancecs, address _Token, address _Conversion, address _Distribution) onlyPayloadSize(5 * 32) onlyOwner public returns (bool) {
    setContract("Token1st", _Tokens1st);
    setContract("Balances", _Balancecs);
    setContract("Token", _Token);
    setContract("Conversion", _Conversion);
    setContract("Distribution", _Distribution);
    return true;
  }
}
