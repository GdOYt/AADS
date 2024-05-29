contract bioCryptToken is ERC223Interface, HasNoEther, HasNoTokens, Claimable, PausableToken, CappedToken {
  string public constant name = "BioCrypt";
  string public constant symbol = "BIO";
  uint8 public constant decimals = 8;
  event Fused();
  bool public fused = false;
  constructor() public CappedToken(1) PausableToken() {
    cap = 1000000000 * (10 ** uint256(decimals));  
  }
    function transfer(address _to, uint _value, bytes _data) public whenNotPaused returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
        bytes memory empty;
        return transfer(_to, _value, empty);
    }
  modifier whenNotFused() {
    require(!fused);
    _;
  }
  function pause() whenNotFused public {
    return super.pause();
  }
  function fuse() whenNotFused onlyOwner public {
    fused = true;
    emit Fused();
  }
}
