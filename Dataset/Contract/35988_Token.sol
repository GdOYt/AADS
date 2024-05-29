contract Token is Crowdsale {
    string  public standard    = 'Token 0.1';
    string  public name        = 'BREMP';
    string  public symbol      = "BREMP";
    uint8   public decimals    = 0;
    mapping (address => mapping (address => uint)) public allowed;
    event Approval(address indexed owner, address indexed spender, uint value);
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }
    function Token(address _neurodao, uint _etherPrice)
        payable Crowdsale(_neurodao, _etherPrice) {}
    function transfer(address _to, uint256 _value)
        public enabledState onlyPayloadSize(2 * 32) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        if (holders[_to] != true) {
            holders[_to] = true;
            holdersIter[numberOfHolders++] = _to;
        }
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    function transferFrom(address _from, address _to, uint _value)
        public enabledState onlyPayloadSize(3 * 32) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);  
        require(allowed[_from][msg.sender] >= _value);
        if (holders[_to] != true) {
            holders[_to] = true;
            holdersIter[numberOfHolders++] = _to;
        }
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }
    function approve(address _spender, uint _value) public enabledState {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }
    function allowance(address _owner, address _spender) public constant enabledState
        returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}
