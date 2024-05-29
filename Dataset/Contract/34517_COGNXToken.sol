contract COGNXToken is StandardToken {
    uint8 public constant decimals = 18;
    string public constant name = 'COGNX';
    string public constant symbol = 'COGNX';
    string public constant version = '1.0.0';
    uint256 public totalSupply = 15000000 * 10 ** uint256(decimals);
    function COGNXToken() public {
        balances[msg.sender] = totalSupply;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
