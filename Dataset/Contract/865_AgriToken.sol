contract AgriToken is ERC20Interface, Owned {
    using SafeMath for uint;
    uint256 constant public MAX_SUPPLY = 1000000000000000000000000000; 
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    bool public isAllowingTransfers;
    mapping (address => bool) public administrators;
    modifier allowingTransfers() {
        require(isAllowingTransfers);
        _;
    }
    modifier onlyAdmin() {
        require(administrators[msg.sender]);
        _;
    }
    event Burn(address indexed burner, uint256 value); 
    event AllowTransfers ();
    event DisallowTransfers ();
    constructor(uint initialTokenSupply) public {
        symbol = "AGRI";
        name = "AgriChain";
        decimals = 18;
        _totalSupply = initialTokenSupply * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) public allowingTransfers returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public allowingTransfers returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    function () public payable {
        revert();
    }
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyAdmin returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    function mintTokens(uint256 _value) public onlyAdmin {
        require(_totalSupply.add(_value) <= MAX_SUPPLY);
        balances[msg.sender] = balances[msg.sender].add(_value);
        _totalSupply = _totalSupply.add(_value);
        emit Transfer(0, msg.sender, _value);      
    }    
    function burn(uint256 _value) public onlyAdmin {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
    function allowTransfers() public onlyAdmin {
        isAllowingTransfers = true;
        emit AllowTransfers();
    }
    function disallowTransfers() public onlyAdmin {
        isAllowingTransfers = false;
        emit DisallowTransfers();
    }
    function addAdministrator(address _admin) public onlyOwner {
        administrators[_admin] = true;
    }
    function removeAdministrator(address _admin) public onlyOwner {
        administrators[_admin] = false;
    }
}
