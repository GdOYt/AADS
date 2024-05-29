contract RestrictedToken is BasicToken, Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  address public issuer;
  uint256 public vestingPeriod;
  mapping(address => bool) public authorizedRecipients;
  mapping(address => bool) public erc223Recipients;
  mapping(address => uint256) public lastIssuedTime;
  event Issue(address indexed to, uint256 value);
  modifier onlyIssuer() {
    require(msg.sender == issuer);
    _;
  }
  modifier isAuthorizedRecipient(address _recipient) {
    require(authorizedRecipients[_recipient]);
    _;
  }
  constructor (
    uint256 _supply,
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _vestingPeriod,
    address _owner,  
    address _issuer  
  ) public {
    require(_supply != 0);
    require(_owner != address(0));
    require(_issuer != address(0));
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    vestingPeriod = _vestingPeriod;
    owner = _owner;
    issuer = _issuer;
    totalSupply_ = _supply;
    balances[_issuer] = _supply;
    emit Transfer(address(0), _issuer, _supply);
  }
  function authorize(address _recipient, bool _isERC223) public onlyOwner {
    require(_recipient != address(0));
    authorizedRecipients[_recipient] = true;
    erc223Recipients[_recipient] = _isERC223;
  }
  function deauthorize(address _recipient) public onlyOwner isAuthorizedRecipient(_recipient) {
    authorizedRecipients[_recipient] = false;
    erc223Recipients[_recipient] = false;
  }
  function transfer(address _to, uint256 _value) public isAuthorizedRecipient(_to) returns (bool) {
    if (erc223Recipients[_to]) {
      BasicERC223Receiver receiver = BasicERC223Receiver(_to);
      bytes memory empty;
      receiver.tokenFallback(msg.sender, _value, empty);
    }
    return super.transfer(_to, _value);
  }
  function issue(address _to, uint256 _value) public onlyIssuer returns (bool) {
    lastIssuedTime[_to] = block.timestamp;
    emit Issue(_to, _value);
    return super.transfer(_to, _value);
  }
}
