contract LescovexERC20 is Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping (address => timeHold) holded;
    struct timeHold{
        uint256[] amount;
        uint256[] time;
        uint256 length;
    }
    string public constant standard = "ERC20 Lescovex ISC Income Smart Contract";
    uint8 public constant decimals = 8;  
    uint256 public holdMax = 100;
    uint256 public totalSupply;
    uint256 public holdTime;
    string public name;
    string public symbol;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    function holdedOf(address _owner) public view returns (uint256) {
        uint256 requiredTime = block.timestamp - holdTime;
        uint256 iValid = 0;                          
        uint256 iNotValid = holded[_owner].length;   
        if (iNotValid == 0                           
        || holded[_owner].time[iValid] >= requiredTime) {  
            return 0;
        }
        uint256 i = iNotValid / 2;   
        while (i > iValid) {   
            if (holded[_owner].time[i] < requiredTime) {
                iValid = i;    
            } else {
                iNotValid = i;  
            }
            i = (iNotValid + iValid) / 2;
        }
        return holded[_owner].amount[iValid];
    }
    function hold(address _to, uint256 _value) internal {
        assert(holded[_to].length < holdMax);
        uint256 len = holded[_to].length;
        uint256 accumulatedValue = (len == 0 ) ?
            _value :
            _value + holded[_to].amount[len - 1];
        holded[_to].amount.push(accumulatedValue);
        holded[_to].time.push(block.timestamp);
        holded[_to].length++;
    }
    function setHoldTime(uint256 _value) external onlyOwner{
      holdTime = _value;
    }
    function setHoldMax(uint256 _value) external onlyOwner{
      holdMax = _value;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        delete holded[msg.sender];
        hold(msg.sender,balances[msg.sender]);
        hold(_to,_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        delete holded[_from];
        hold(_from,balances[_from]);
        hold(_to,_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}
