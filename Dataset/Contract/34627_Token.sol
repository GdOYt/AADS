contract Token is Crowdsale, ERC20 {
    mapping(address => uint) internal balances;
    mapping(address => mapping(address => uint)) public allowed;
    uint8 public constant decimals = 8;
    function Token() payable Crowdsale() {}
    function balanceOf(address who) constant returns(uint) {
        return balances[who];
    }
    function transfer(address _to, uint _value) public completedSaleState onlyPayloadSize(2 * 32) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);  
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) public completedSaleState onlyPayloadSize(3 * 32) {
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);  
        require(allowed[_from][msg.sender] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }
    function approve(address _spender, uint _value) public completedSaleState {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }
    function allowance(address _owner, address _spender) public constant completedSaleState returns(uint remaining) {
        return allowed[_owner][_spender];
    }
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }
}
