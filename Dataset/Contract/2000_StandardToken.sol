contract StandardToken is ERC20 {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) allowed;
    mapping(address => uint256) balances;
    function transfer(address _to, uint256 _value) public returns (bool){
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function balanceOf(address _owner) view public returns (uint256 balance){
        return balances[_owner];
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        uint256 _allowance = allowed[_from][msg.sender];
        require (balances[_from] >= _value);
        require (_allowance >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool){
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) view public returns (uint256 remaining){
        return allowed[_owner][_spender];
    }
}
