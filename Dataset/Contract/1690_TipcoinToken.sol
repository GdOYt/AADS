contract TipcoinToken is StandardToken, Pausable, BurnableToken, ERC223Interface {
  using SafeMath for uint256;
  string public constant name = "Tipcoin";
  string public constant symbol = "TIPC";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 1000000000;
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY * 10 ** 18;
    balances[owner] = totalSupply_;
    emit Transfer(address(0), owner, INITIAL_SUPPLY);
  }    
  function transfer(address _to, uint256 _value, bytes _data, string _fallback) public whenNotPaused returns (bool) {
    require( _to != address(0));
    if (isContract(_to)) {            
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      assert(_to.call.value(0)(bytes4(keccak256(abi.encodePacked(_fallback))), msg.sender, _value, _data));
      if (_data.length == 0) {
        emit Transfer(msg.sender, _to, _value);
      } else {
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
      }
      return true;
    } else {
      return transferToAddress(msg.sender, _to, _value, _data);
    }
  }
  function transfer(address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
    if (isContract(_to)) {
      return transferToContract(msg.sender, _to, _value, _data);
    } else {
      return transferToAddress(msg.sender, _to, _value, _data);
    }
  }
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
      bytes memory empty;
      if (isContract(_to)) {
          return transferToContract(msg.sender, _to, _value, empty);
      } else {
          return transferToAddress(msg.sender, _to, _value, empty);
      }
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool){      
    require( _to != address(0));
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    bytes memory empty;
    if (isContract(_to)) {
        return transferToContract(_from, _to, _value, empty);
      } else {
        return transferToAddress(_from, _to, _value, empty);
      }
  }
  function isContract(address _addr) internal view returns (bool) {
    uint length;
    assembly {
      length := extcodesize(_addr)
    }
    return (length >0);
  }
  function transferToAddress(address _from, address _to, uint256 _value, bytes _data) private returns (bool) {
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if (_data.length == 0) {
      emit Transfer(_from, _to, _value);
    } else {
      emit Transfer(_from, _to, _value);
      emit Transfer(_from, _to, _value, _data);
    }    
    return true;
  }
  function transferToContract(address _from, address _to, uint256 _value, bytes _data) private returns (bool) {
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    ERC223Receiver receiver = ERC223Receiver(_to);
    receiver.tokenFallback(_from, _value, _data);
    if (_data.length == 0) {
      emit Transfer(_from, _to, _value);
    } else {
      emit Transfer(_from, _to, _value);
      emit Transfer(_from, _to, _value, _data);
    }    
    return true;   
  }
}
