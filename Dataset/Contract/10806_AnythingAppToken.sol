contract AnythingAppToken is Burnable, Ownable {
  string public constant name = "AnyCoin";
  string public constant symbol = "ANY";
  uint8 public constant decimals = 18;
  uint public constant INITIAL_SUPPLY = 400000000 * 1 ether;
  address public releaseAgent;
  bool public released = false;
  mapping (address => bool) public transferAgents;
  modifier canTransfer(address _sender) {
    require(released || transferAgents[_sender]);
    _;
  }
  modifier inReleaseState(bool releaseState) {
    require(releaseState == released);
    _;
  }
  modifier onlyReleaseAgent() {
    require(msg.sender == releaseAgent);
    _;
  }
  function AnythingAppToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
    require(addr != 0x0);
    releaseAgent = addr;
  }
  function release() onlyReleaseAgent inReleaseState(false) public {
    released = true;
  }
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    require(addr != 0x0);
    transferAgents[addr] = state;
  }
  function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }
    function transfer(address _to, uint _value, bytes _data) canTransfer(msg.sender) returns (bool success) {
      require(_to != address(0));
      require(_value <= balances[msg.sender]);
      uint codeLength;
      assembly {
          codeLength := extcodesize(_to)
      }
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      if(codeLength>0) {
          ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
          receiver.tokenFallback(msg.sender, _value, _data);
      }
      Transfer(msg.sender, _to, _value);
      return true;
    }
    function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
      require(_to != address(0));
      require(_value <= balances[msg.sender]);
      uint codeLength;
      bytes memory empty;
      assembly {
          codeLength := extcodesize(_to)
      }
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      if(codeLength>0) {
          ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
          receiver.tokenFallback(msg.sender, _value, empty);
      }
      Transfer(msg.sender, _to, _value);
      return true;
    }
  function burn(uint _value) onlyOwner returns (bool success) {
    return super.burn(_value);
  }
  function burnFrom(address _from, uint _value) onlyOwner returns (bool success) {
    return super.burnFrom(_from, _value);
  }
}
