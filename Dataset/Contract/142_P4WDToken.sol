contract P4WDToken {
  using SafeMath for uint;
  using SafeERC20 for P4WDToken;
  string public name = "Pay 4ward";
  string public constant symbol = "P4WD";
  uint8 public constant decimals = 18;
  uint public constant decimalsFactor = 10 ** uint(decimals);
  uint public cap = 10000000000 * decimalsFactor;
  address public owner;
  mapping (address => bool) public companions;
  address[] public companionsList;
  bool public paused = false;
  mapping(address => uint256) balances;
  uint256 totalSupply_;
  mapping (address => mapping (address => uint256)) internal allowed;
  bool public mintingFinished = false;
  modifier onlyOwner() {
    require((msg.sender == owner) || (companions[msg.sender]));
    _;
  }
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event CompanionAdded(address indexed _companion);
  event CompanionRemoved(address indexed _companion);
  event Pause();
  event Unpause();
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event NameChanged();
  event CapChanged(uint256 oldVal, uint256 newVal);
  function P4WDToken() public {
    paused = true;
    owner = msg.sender;
  }
  function setName(string _name) onlyOwner public {
    require(bytes(_name).length != 0);
    name = _name;
    emit NameChanged();
  }
  function setCap(uint256 _cap) onlyOwner public {
    require(cap > 0);
    require(_cap >= totalSupply_);
    uint256 old = cap;
    cap = _cap;
    emit CapChanged(old, cap);
  }
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  function increaseApproval(address _spender, uint _addedValue) whenNotPaused public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }
  function addCompanion(address _companion) onlyOwner public {
    require(_companion != address(0));
    companions[_companion] = true;
    companionsList.push(_companion);
    emit CompanionAdded(_companion);
  }
  function removeCompanion(address _companion) onlyOwner public {
    require(_companion != address(0));
    companions[_companion] = false;
    emit CompanionRemoved(_companion);
  }
  function companionsListCount() onlyOwner public view returns (uint256) {
    return companionsList.length;
  }
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply_.add(_amount) <= cap);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);  
    return true;
  }
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
  function reclaimToken(P4WDToken token) onlyOwner external {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }
}
