contract StandardToken is ERC223 {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    function StandardToken(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
    function _transfer(address _to, uint256 _value, bytes _data) private returns(bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        bool is_contract = false;
        assembly {
            is_contract := not(iszero(extcodesize(_to)))
        }
        if(is_contract) {
            ERC223Receiving receiver = ERC223Receiving(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) public returns(bool) {
        bytes memory empty;
        return _transfer(_to, _value, empty);
    }
    function transfer(address _to, uint256 _value, bytes _data) public returns(bool) {
        return _transfer(_to, _value, _data);
    }
    function multiTransfer(address[] _to, uint256[] _value) public returns(bool) {
        require(_to.length == _value.length);
        for(uint i = 0; i < _to.length; i++) {
            transfer(_to[i], _value[i]);
        }
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if(_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}
