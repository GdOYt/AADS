contract Standard677Token is ERC677, BasicToken {
  function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
    require(super.transfer(_to, _value));  
    TransferAndCall(msg.sender, _to, _value, _data);
    if (isContract(_to)) return contractFallback(_to, _value, _data);
    return true;
  }
  function contractFallback(address _to, uint _value, bytes _data) private returns (bool) {
    ERC223Receiver receiver = ERC223Receiver(_to);
    require(receiver.tokenFallback(msg.sender, _value, _data));
    return true;
  }
  function isContract(address _addr) private constant returns (bool is_contract) {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}
