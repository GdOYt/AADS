contract StandardToken is ERC20 {
    using SafeMath
    for uint256;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns(bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
