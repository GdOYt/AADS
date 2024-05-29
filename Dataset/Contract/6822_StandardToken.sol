contract StandardToken is controllable, Pausable, Token, Lockable {
    function transfer(address _to, uint256 _value) public whenNotPaused() returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to] && !isBlacklist(msg.sender)) {
            balances[msg.sender] = safeSubtract(balances[msg.sender],_value);
            totalbalances[msg.sender] = safeSubtract(totalbalances[msg.sender],_value);
            balances[_to] = safeAdd(balances[_to],_value);
            totalbalances[_to] = safeAdd(totalbalances[_to],_value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused() returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to] && !isBlacklist(msg.sender)) {
            balances[_to] = safeAdd(balances[_to],_value);
            totalbalances[_to] = safeAdd(totalbalances[_to],_value);
            balances[_from] = safeSubtract(balances[_from],_value);
            totalbalances[_from] = safeSubtract(totalbalances[_from],_value);
            allowed[_from][msg.sender] = safeSubtract(allowed[_from][msg.sender],_value);
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) { 
        return allowed[_owner][_spender];
    }
    mapping (address => mapping (address => uint256)) allowed;
}
