contract BPPToken is StandardToken {
    function () public {
       revert();
    }
    string public name;
    uint8 public decimals; 
    string public symbol;
    string public version = '1.0';
    constructor() public {
        name = 'Bpp';
        decimals = 18;
        symbol = 'BPP';
        totalSupply = 21000000000 * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}
