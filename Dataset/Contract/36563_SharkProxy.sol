contract SharkProxy is Ownable {
  event Deposit(address indexed sender, uint256 value);
  event Withdrawal(address indexed to, uint256 value, bytes data);
  function SharkProxy() {
    owner = msg.sender;
  }
  function getOwner() constant returns (address) {
    return owner;
  }
  function forward(address _destination, uint256 _value, bytes _data) onlyOwner {
    require(_destination != address(0));
    assert(_destination.call.value(_value)(_data));  
    if (_value > 0) {
      Withdrawal(_destination, _value, _data);
    }
  }
  function() payable {
    Deposit(msg.sender, msg.value);
  }
  function tokenFallback(address _from, uint _value, bytes _data) {
  }
}
