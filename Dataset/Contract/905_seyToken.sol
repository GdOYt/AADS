contract  seyToken is ERC20Interface, owned {
    using SafeMath for uint;   
    string public name; 
    string public symbol; 
    uint public decimals;
    uint internal maxSupply; 
    uint public totalSupply; 
    address public beneficiary;
    mapping (address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    constructor(string _name, string _symbol, uint _maxSupply) public {         
        name = _name;    
        symbol = _symbol;    
        decimals = 18;
        maxSupply = _maxSupply * (10 ** decimals);   
        totalSupply = totalSupply.add(maxSupply);
        beneficiary = msg.sender;
        balances[beneficiary] = balances[beneficiary].add(totalSupply);
    }
    function totalSupply() public constant returns (uint) {
        return totalSupply  - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address _to, uint _value) public whenNotPaused returns (bool success) {
        if (balances[msg.sender] < _value) revert() ;           
        if (balances[_to] + _value < balances[_to]) revert(); 
        balances[msg.sender] = balances[msg.sender].sub(_value); 
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);          
        return true;
    }
    function transferByOwner(address _from, address _to, uint _value) public onlyOwner returns (bool success) {
        if (balances[_from] < _value) revert(); 
        if (balances[_to] + _value < balances[_to]) revert();
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value); 
        emit Transfer(_from, _to, _value);
        emit TransferByOwner(_from, _to, _value);
        return true;
    }
    function approve(address spender, uint tokens) public whenNotPaused returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
   function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool success) {
        if (balances[_from] < _value) revert();                
        if (balances[_to] + _value < balances[_to]) revert(); 
        if (_value > allowed[_from][msg.sender]) revert(); 
        balances[_from] = balances[_from].sub(_value);                     
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value); 
        emit Transfer(_from, _to, _value);
        return true;
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function () public payable {
        revert();  
    }  
}
