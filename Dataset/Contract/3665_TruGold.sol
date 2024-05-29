contract TruGold is ERC20Interface, MultiOwnable {
  using SafeMath for uint;
  string public symbol;
  string public  name;
  uint8 public decimals;
  uint _totalSupply;
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  mapping (bytes32 => Transaction) public pendingTransactions;  
  struct Transaction {
    address from;
    address to;
    uint value;
  }
  constructor(address target, address _owner1, address _owner2)
    MultiOwnable(_owner1, _owner2) public {
    symbol = "TruGold";
    name = "TruGold";
    decimals = 18;
    _totalSupply = 300000000 * 10**uint(decimals);
    balances[target] = _totalSupply;
    emit Transfer(address(0), target, _totalSupply);
  }
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return balances[tokenOwner];
  }
  function transfer(address to, uint tokens)
    public
    onlyIfUnlocked
    returns (bool success) {
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  function ownerTransfer(address from, address to, uint value)
    public onlyOwner
    returns (bytes32 operation) {
    operation = keccak256(abi.encodePacked(msg.data, block.number));
    if (!approveOwnerTransfer(operation) && pendingTransactions[operation].to == 0) {
      pendingTransactions[operation].from = from;
      pendingTransactions[operation].to = to;
      pendingTransactions[operation].value = value;
      emit ConfirmationNeeded(operation, from, value, to);
    }
    return operation;
  }
  function approveOwnerTransfer(bytes32 operation)
    public
    onlyManyOwners(operation)
    returns (bool success) {
    Transaction storage transaction = pendingTransactions[operation];
    balances[transaction.from] = balances[transaction.from].sub(transaction.value);
    balances[transaction.to] = balances[transaction.to].add(transaction.value);
    delete pendingTransactions[operation];
    emit Transfer(transaction.from, transaction.to, transaction.value);
    return true;
  }
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
  function transferFrom(address from, address to, uint tokens) public onlyIfUnlocked returns (bool success) {
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
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner1, tokens);
  }
}
