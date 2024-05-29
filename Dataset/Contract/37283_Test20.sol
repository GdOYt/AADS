contract Test20 is StandardToken {
  string public constant name = "Test20";
  string public constant symbol = "TST";
  uint public constant decimals = 18;
  string public version = "1.0";
  uint public totalSupply = 10000; 
  function Test20() {
      balances[msg.sender] = totalSupply;  
  }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
  }
