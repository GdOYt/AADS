contract VibeoToken is StandardToken, BurnableToken, NoOwner, CustomPausable {
  string public constant name = "Vibeo";
  string public constant symbol = "VBEO";
  uint8 public constant decimals = 18;
  uint256 public constant MAX_SUPPLY = 950000000 * (10 ** uint256(decimals));  
  bool public transfersEnabled;
  bool public softCapReached;
  mapping(bytes32 => bool) private mintingList;
  mapping(address => bool) private transferAgents;
  uint256 public icoEndDate;
  uint256 private year = 365 * 1 days;
  event TransferAgentSet(address agent, bool state);
  event BulkTransferPerformed(address[] _destinations, uint256[] _amounts);
  constructor() public {
    mintTokens(msg.sender, 453000000);
    setTransferAgent(msg.sender, true);
  }
  modifier canTransfer(address _from) {
    if (!transfersEnabled && !transferAgents[_from]) {
      revert();
    }
    _;
  }
  function computeHash(string _key) private pure returns(bytes32){
    return keccak256(abi.encodePacked(_key));
  }
  modifier whenNotMinted(string _key) {
    if(mintingList[computeHash(_key)]) {
      revert();
    }
    _;
  }
  function setICOEndDate(uint256 _date) public whenNotPaused onlyWhitelisted {
    require(icoEndDate == 0);
    icoEndDate = _date;
  }
  function setSoftCapReached() public onlyWhitelisted {
    require(!softCapReached);
    softCapReached = true;
  }
  function enableTransfers() public onlyWhitelisted {
    require(icoEndDate > 0);
    require(now >= icoEndDate);
    require(!transfersEnabled);
    transfersEnabled = true;
  }
  function disableTransfers() public onlyWhitelisted {
    require(transfersEnabled);
    transfersEnabled = false;
  }
  function mintOnce(string _key, address _to, uint256 _amount) private whenNotPaused whenNotMinted(_key) {
    mintTokens(_to, _amount);
    mintingList[computeHash(_key)] = true;
  }
  function mintTeamTokens() public onlyWhitelisted {
    require(icoEndDate > 0);
    require(softCapReached);
    if(now < icoEndDate + year) {
      revert("Access is denied. The team tokens are locked for 1 year from the ICO end date.");
    }
    mintOnce("team", msg.sender, 50000000);
  }
  function mintTreasuryTokens() public onlyWhitelisted {
    require(icoEndDate > 0);
    require(softCapReached);
    mintOnce("treasury", msg.sender, 90000000);
  }
  function mintAdvisorTokens() public onlyWhitelisted {
    require(icoEndDate > 0);
    if(now < icoEndDate + year) {
      revert("Access is denied. The advisor tokens are locked for 1 year from the ICO end date.");
    }
    mintOnce("advisorsTokens", msg.sender, 80000000);
  }
  function mintPartnershipTokens() public onlyWhitelisted {
    require(softCapReached);
    mintOnce("partnerships", msg.sender, 60000000);
  }
  function mintCommunityRewards() public onlyWhitelisted {
    require(softCapReached);
    mintOnce("communityRewards", msg.sender, 90000000);
  }
  function mintUserAdoptionTokens() public onlyWhitelisted {
    require(icoEndDate > 0);
    require(softCapReached);
    mintOnce("useradoption", msg.sender, 95000000);
  }
  function mintMarketingTokens() public onlyWhitelisted {
    require(softCapReached);
    mintOnce("marketing", msg.sender, 32000000);
  }
  function setTransferAgent(address _agent, bool _state) public whenNotPaused onlyWhitelisted {
    transferAgents[_agent] = _state;
    emit TransferAgentSet(_agent, _state);
  }
  function isTransferAgent(address _address) public constant onlyWhitelisted returns(bool) {
    return transferAgents[_address];
  }
  function transfer(address _to, uint256 _value) public whenNotPaused canTransfer(msg.sender) returns (bool) {
    require(_to != address(0));
    return super.transfer(_to, _value);
  }
  function mintTokens(address _to, uint256 _value) private {
    require(_to != address(0));
    _value = _value.mul(10 ** uint256(decimals));
    require(totalSupply_.add(_value) <= MAX_SUPPLY);
    totalSupply_ = totalSupply_.add(_value);
    balances[_to] = balances[_to].add(_value);
  }
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from) public returns (bool) {
    require(_to != address(0));
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public canTransfer(msg.sender) returns (bool) {
    require(_spender != address(0));
    return super.approve(_spender, _value);
  }
  function increaseApproval(address _spender, uint256 _addedValue) public canTransfer(msg.sender) returns(bool) {
    require(_spender != address(0));
    return super.increaseApproval(_spender, _addedValue);
  }
  function decreaseApproval(address _spender, uint256 _subtractedValue) public canTransfer(msg.sender) whenNotPaused returns (bool) {
    require(_spender != address(0));
    return super.decreaseApproval(_spender, _subtractedValue);
  }
  function sumOf(uint256[] _values) private pure returns(uint256) {
    uint256 total = 0;
    for (uint256 i = 0; i < _values.length; i++) {
      total = total.add(_values[i]);
    }
    return total;
  }
  function bulkTransfer(address[] _destinations, uint256[] _amounts) public onlyWhitelisted {
    require(_destinations.length == _amounts.length);
    uint256 requiredBalance = sumOf(_amounts);
    require(balances[msg.sender] >= requiredBalance);
    for (uint256 i = 0; i < _destinations.length; i++) {
     transfer(_destinations[i], _amounts[i]);
    }
    emit BulkTransferPerformed(_destinations, _amounts);
  }
  function burn(uint256 _value) public whenNotPaused {
    super.burn(_value);
  }
}
