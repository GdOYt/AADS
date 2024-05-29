contract CoinLoanCS is ERC20, Owned {
  using SafeMath for uint256;
  string public symbol;
  string public  name;
  uint256 public decimals;
  uint256 _totalSupply;
  address public token;
  uint256 public price;
  mapping(address => uint256) balances;
  mapping(address => mapping(string => uint256)) orders;
  event TransferETH(address indexed from, address indexed to, uint256 eth);
  event Sell(address indexed to, uint256 tokens);
  constructor() public {
    symbol = "CLT_CS";
    name = "CoinLoan CryptoStock Promo Token";
    decimals = 8;
    token = 0x2001f2A0Cf801EcFda622f6C28fb6E10d803D969;
    price = 3000000;   
    _totalSupply = 100000 * 10**decimals;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }
  function setToken(address newTokenAddress) public onlyOwner returns (bool success) {
    token = newTokenAddress;
    return true;
  }
  function getToken() public view returns (address) {
    return token;
  }
  function setPrice(uint256 newPrice) public onlyOwner returns (bool success) {
    price = newPrice;
    return true;
  }
  function getPrice() public view returns (uint256) {
    return price;
  }
  function totalSupply() public view returns (uint256) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function changeTotalSupply(uint256 newSupply) public onlyOwner returns (bool success) {
    require(newSupply >= 0 && (
      newSupply >= _totalSupply || _totalSupply - newSupply <= balances[owner]
    ));
    uint256 diff = 0;
    if (newSupply >= _totalSupply) {
      diff = newSupply.sub(_totalSupply);
      balances[owner] = balances[owner].add(diff);
      emit Transfer(address(0), owner, diff);
    } else {
      diff = _totalSupply.sub(newSupply);
      balances[owner] = balances[owner].sub(diff);
      emit Transfer(owner, address(0), diff);
    }
    _totalSupply = newSupply;
    return true;
  }
  function balanceOf(address tokenOwner) public view returns (uint256 balance) {
    return balances[tokenOwner];
  }
  function orderTokensOf(address customer) public view returns (uint256 balance) {
    return orders[customer]['tokens'];
  }
  function orderEthOf(address customer) public view returns (uint256 balance) {
    return orders[customer]['eth'];
  }
  function cancelOrder(address customer) public onlyOwner returns (bool success) {
    orders[customer]['eth'] = 0;
    orders[customer]['tokens'] = 0;
    return true;
  }
  function _checkOrder(address customer) private returns (uint256) {
    require(price > 0);
    if (orders[customer]['tokens'] <= 0 || orders[customer]['eth'] <= 0) {
      return 0;
    }
    uint256 decimalsDiff = 10 ** (18 - 2 * decimals);
    uint256 eth = orders[customer]['eth'];
    uint256 tokens = orders[customer]['eth'] / price / decimalsDiff;
    if (orders[customer]['tokens'] < tokens) {
      tokens = orders[customer]['tokens'];
      eth = tokens * price * decimalsDiff;
    }
    ERC20 tokenInstance = ERC20(token);
    require(tokenInstance.balanceOf(this) >= tokens);
    orders[customer]['tokens'] = orders[customer]['tokens'].sub(tokens);
    orders[customer]['eth'] = orders[customer]['eth'].sub(eth);
    tokenInstance.transfer(customer, tokens);
    emit Sell(customer, tokens);
    return tokens;
  }
  function checkOrder(address customer) public onlyOwner returns (uint256) {
    return _checkOrder(customer);
  }
  function transfer(address to, uint256 tokens) public returns (bool success) {
    require(msg.sender == owner || to == owner || to == address(this));
    address receiver = msg.sender == owner ? to : owner;
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[receiver] = balances[receiver].add(tokens);
    emit Transfer(msg.sender, receiver, tokens);
    if (receiver == owner) {
      orders[msg.sender]['tokens'] = orders[msg.sender]['tokens'].add(tokens);
      _checkOrder(msg.sender);
    }
    return true;
  }
  function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
    tokenOwner;
    spender;
    return uint256(0);
  }
  function approve(address spender, uint tokens) public returns (bool success) {
    spender;
    tokens;
    return true;
  }
  function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
    from;
    to;
    tokens;
    return true;
  }
  function () public payable {
    owner.transfer(msg.value);
    orders[msg.sender]['eth'] = orders[msg.sender]['eth'].add(msg.value);
    _checkOrder(msg.sender);
    emit TransferETH(msg.sender, address(this), msg.value);
  }
  function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
    return ERC20(tokenAddress).transfer(owner, tokens);
  }
  function transferToken(uint256 tokens) public onlyOwner returns (bool success) {
    return transferAnyERC20Token(token, tokens);
  }
  function returnFrom(address tokenOwner, uint256 tokens) public onlyOwner returns (bool success) {
    balances[tokenOwner] = balances[tokenOwner].sub(tokens);
    balances[owner] = balances[owner].add(tokens);
    emit Transfer(tokenOwner, owner, tokens);
    return true;
  }
  function nullifyFrom(address tokenOwner) public onlyOwner returns (bool success) {
    return returnFrom(tokenOwner, balances[tokenOwner]);
  }
}
