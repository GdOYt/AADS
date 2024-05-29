contract Asset is DSMath, AssetInterface, ERC223Interface {
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;
    function transfer(address _to, uint _value)
        public
        returns (bool success)
    {
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender] >= _value);  
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        Transfer(msg.sender, _to, _value, empty);
        return true;
    }
    function transfer(address _to, uint _value, bytes _data)
        public
        returns (bool success)
    {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender] >= _value);  
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint _value) public returns (bool) {
        require(_spender != 0x0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender)
        constant
        public
        returns (uint)
    {
        return allowed[_owner][_spender];
    }
    function balanceOf(address _owner) constant public returns (uint) {
        return balances[_owner];
    }
}
