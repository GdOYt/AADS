contract Standard223Receiver is ERC223Receiver {
  Tkn tkn;
  struct Tkn {
    address addr;
    address sender;  
    uint256 value;
  }
  bool __isTokenFallback;
  modifier tokenPayable {
    require(__isTokenFallback);
    _;
  }
  function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok) {
    if (!supportsToken(msg.sender)) {
      return false;
    }
    tkn = Tkn(msg.sender, _sender, _value);
    __isTokenFallback = true;
    if (!address(this).delegatecall(_data)) {
      __isTokenFallback = false;
      return false;
    }
    __isTokenFallback = false;
    return true;
  }
  function supportsToken(address token) public constant returns (bool);
}
