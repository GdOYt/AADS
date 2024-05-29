contract CHStock is ERC20Interface {
  using SafeMath for uint256;
  event RedeemShares(
    address indexed user,
    uint256 shares,
    uint256 dividends
  );
  string public name = "ChickenHuntStock";
  string public symbol = "CHS";
  uint8 public decimals = 18;
  uint256 public totalShares;
  uint256 public dividendsPerShare;
  uint256 public constant CORRECTION = 1 << 64;
  mapping (address => uint256) public ethereumBalance;
  mapping (address => uint256) internal shares;
  mapping (address => uint256) internal refund;
  mapping (address => uint256) internal deduction;
  mapping (address => mapping (address => uint256)) internal allowed;
  function redeemShares() public {
    uint256 _shares = shares[msg.sender];
    uint256 _dividends = dividendsOf(msg.sender);
    delete shares[msg.sender];
    delete refund[msg.sender];
    delete deduction[msg.sender];
    totalShares = totalShares.sub(_shares);
    ethereumBalance[msg.sender] = ethereumBalance[msg.sender].add(_dividends);
    emit RedeemShares(msg.sender, _shares, _dividends);
  }
  function transfer(address _to, uint256 _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool)
  {
    require(_value <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  function dividendsOf(address _shareholder) public view returns (uint256) {
    return dividendsPerShare.mul(shares[_shareholder]).add(refund[_shareholder]).sub(deduction[_shareholder]) / CORRECTION;
  }
  function totalSupply() public view returns (uint256) {
    return totalShares;
  }
  function balanceOf(address _owner) public view returns (uint256) {
    return shares[_owner];
  }
  function allowance(address _owner, address _spender)
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }
  function _giveShares(address _user, uint256 _ethereum) internal {
    if (_ethereum > 0) {
      totalShares = totalShares.add(_ethereum);
      deduction[_user] = deduction[_user].add(dividendsPerShare.mul(_ethereum));
      shares[_user] = shares[_user].add(_ethereum);
      dividendsPerShare = dividendsPerShare.add(_ethereum.mul(CORRECTION) / totalShares);
      emit Transfer(address(0), _user, _ethereum);
    }
  }
  function _transfer(address _from, address _to, uint256 _value) internal {
    require(_to != address(0));
    require(_value <= shares[_from]);
    uint256 _rawProfit = dividendsPerShare.mul(_value);
    uint256 _refund = refund[_from].add(_rawProfit);
    uint256 _min = _refund < deduction[_from] ? _refund : deduction[_from];
    refund[_from] = _refund.sub(_min);
    deduction[_from] = deduction[_from].sub(_min);
    deduction[_to] = deduction[_to].add(_rawProfit);
    shares[_from] = shares[_from].sub(_value);
    shares[_to] = shares[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }
}
