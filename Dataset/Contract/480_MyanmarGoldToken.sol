contract MyanmarGoldToken is ERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 totalSupply_;
    string public constant name = "MyanmarGoldToken"; 
    string public constant symbol = "MGC"; 
    uint8 public constant decimals = 18; 
    event Burn(address indexed burner, uint256 value);
    constructor(address _icoAddress) public {
        totalSupply_ = 1000000000 * (10 ** uint256(decimals));
        balances[_icoAddress] = totalSupply_;
        emit Transfer(address(0), _icoAddress, totalSupply_);
    }
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function batchTransfer(address[] _tos, uint256[] _values) public returns (bool) {
        require(_tos.length == _values.length);
        uint256 arrayLength = _tos.length;
        for(uint256 i = 0; i < arrayLength; i++) {
            transfer(_tos[i], _values[i]);
        }
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
}
