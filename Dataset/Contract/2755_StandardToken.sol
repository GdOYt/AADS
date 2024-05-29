contract StandardToken is ERC20Token {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    constructor(string _name, string _symbol, uint8 _decimals) internal {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    function balanceOf(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        executeTransfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].minus(_value);
        executeTransfer(_from, _to, _value);
        return true;
    }
    function executeTransfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        require(_value != 0 && _value <= balances[_from]);
        balances[_from] = balances[_from].minus(_value);
        balances[_to] = balances[_to].plus(_value);
        emit Transfer(_from, _to, _value);
    }
}
