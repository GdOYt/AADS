contract Ethername is EthernameRaw {
  function Ethername() public {
    commission = 200;
    nameToRecord[bytes32('')] = Record(this, 0);
    _register(bytes32('ethername'), this);
    _register(bytes32('root'), msg.sender);
  }
  function register(string _name) external payable {
    rawRegister(_stringToBytes32(_name));
  }
  function transfer(address _to, string _name) external {
    rawTransfer(_to, _stringToBytes32(_name));
  }
  function approve(address _to, string _name) external {
    rawApprove(_to, _stringToBytes32(_name));
  }
  function transferFrom(address _from, address _to, string _name) external {
    rawTransferFrom(_from, _to, _stringToBytes32(_name));
  }
  function setPrice(string _name, uint256 _price) external {
    rawSetPrice(_stringToBytes32(_name), _price);
  }
  function buy(string _name) external payable {
    rawBuy(_stringToBytes32(_name));
  }
  function useName(string _name) external {
    rawUseName(_stringToBytes32(_name));
  }
  function setAttribute(string _name, string _key, bytes _value) external {
    rawSetAttribute(_stringToBytes32(_name), _stringToBytes32(_key), _value);
  }
  function wipeAttributes(string _name, bytes32[] _keys) external {
    rawWipeAttributes(_stringToBytes32(_name), _keys);
  }
  function sendEther(string _name) external payable returns (bool _result) {
    _result = rawSendEther(_stringToBytes32(_name));
  }
  function nameOf(address _address) external view returns (string _name) {
    _name = _bytes32ToString(rawNameOf(_address));
  }
  function ownerOf(string _name) external view returns (address _owner) {
    _owner = rawOwnerOf(_stringToBytes32(_name));
  }
  function detailsOf(string _name, string _key)
    external
    view
    returns (address _owner, uint256 _price, bytes _value)
  {
    return rawDetailsOf(_stringToBytes32(_name), _stringToBytes32(_key));
  }
}
