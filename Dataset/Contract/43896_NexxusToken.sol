contract NexxusToken is StandardToken {
    function () {return;}
    string public name = "Nexxus";
    uint8 public decimals = 8;
    string public symbol = "NXX";
    address public owner;
    function NexxusToken() {
        totalSupply = 31800000000000000;
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { return; }
        return true;
    }
	function mintToken(uint256 _amount) {
        if (msg.sender == owner) {
    		totalSupply += _amount;
            balances[owner] += _amount;
    		Transfer(0, owner, _amount);
        }
	}
	function disableToken(bool _disable) { 
        if (msg.sender == owner)
			disabled = _disable;
    }
}
