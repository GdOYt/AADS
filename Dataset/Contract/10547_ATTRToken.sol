contract ATTRToken is CappedToken, DetailedERC20 {
  using SafeMath for uint256;
  uint256 public constant TOTAL_SUPPLY       = uint256(1000000000);
  uint256 public constant TOTAL_SUPPLY_ACES  = uint256(1000000000000000000000000000);
  uint256 public constant CROWDSALE_MAX_ACES = uint256(500000000000000000000000000);
  address public crowdsaleContract;
  uint256 public crowdsaleMinted = uint256(0);
  uint256 public releaseTime = uint256(1536278399);  
  bool    public fundingLowcapReached = false;
  bool    public isReleased = false;
  mapping (address => bool) public agents;
  mapping (address => bool) public transferWhitelist;
  constructor() public 
    CappedToken(TOTAL_SUPPLY_ACES) 
    DetailedERC20("Attrace", "ATTR", uint8(18)) {
    transferWhitelist[msg.sender] = true;
    agents[msg.sender] = true;
  }
  modifier isInitialized() {
    require(crowdsaleContract != address(0));
    require(releaseTime > 0);
    _;
  }
  function setAgent(address _address, bool _status) public onlyOwner {
    require(_address != address(0));
    agents[_address] = _status;
  }
  modifier onlyAgents() {
    require(agents[msg.sender] == true);
    _;
  }
  function setCrowdsaleContract(address _crowdsaleContract) public onlyAgents {
    require(_crowdsaleContract != address(0));
    crowdsaleContract = _crowdsaleContract;
  }
  function setTransferWhitelist(address _address, bool _canTransfer) public onlyAgents {
    require(_address != address(0));
    transferWhitelist[_address] = _canTransfer;
  }
  function setReleaseTime(uint256 _time) public onlyAgents {
    require(_time > block.timestamp);
    require(isReleased == false);
    releaseTime = _time;
  }
  function setFundingLowcapReached(uint256 _verification) public onlyAgents {
    require(_verification == uint256(20234983249), "wrong verification code");
    fundingLowcapReached = true;
  }
  function markReleased() public {
    if (isReleased == false && _now() > releaseTime) {
      isReleased = true;
    }
  }
  modifier hasMintPermission() {
    require(msg.sender == crowdsaleContract || agents[msg.sender] == true);
    _;
  }
  function mint(address _to, uint256 _aces) public canMint hasMintPermission returns (bool) {
    if (msg.sender == crowdsaleContract) {
      require(crowdsaleMinted.add(_aces) <= CROWDSALE_MAX_ACES);
      crowdsaleMinted = crowdsaleMinted.add(_aces);
    }
    return super.mint(_to, _aces);
  }
  modifier canTransfer(address _from) {
    if (transferWhitelist[_from] == false) {
      require(block.timestamp >= releaseTime);
      require(fundingLowcapReached == true);
    }
    _;
  }
  function transfer(address _to, uint256 _aces) 
    public
    isInitialized
    canTransfer(msg.sender) 
    tokensAreUnlocked(msg.sender, _aces)
    returns (bool) {
      markReleased();
      return super.transfer(_to, _aces);
    }
  function transferFrom(address _from, address _to, uint256 _aces) 
    public
    isInitialized
    canTransfer(_from) 
    tokensAreUnlocked(_from, _aces)
    returns (bool) {
      markReleased();
      return super.transferFrom(_from, _to, _aces);
    }
  struct VestingRule {
    uint256 aces;
    uint256 unlockTime;
    bool    processed;
  }
  mapping (address => uint256) public lockedAces;
  modifier tokensAreUnlocked(address _from, uint256 _aces) {
    if (lockedAces[_from] > uint256(0)) {
      require(balanceOf(_from).sub(lockedAces[_from]) >= _aces);
    }
    _;
  }
  mapping (address => VestingRule[]) public vestingRules;
  function processVestingRules(address _address) public onlyAgents {
    _processVestingRules(_address);
  }
  function processMyVestingRules() public {
    _processVestingRules(msg.sender);
  }
  function addVestingRule(address _address, uint256 _aces, uint256 _unlockTime) public {
    require(_aces > 0);
    require(_address != address(0));
    require(_unlockTime > _now());
    if (_now() < releaseTime) {
      require(msg.sender == owner);
    } else {
      require(msg.sender == crowdsaleContract || msg.sender == owner);
      require(_now() < releaseTime.add(uint256(2592000)));
    }
    vestingRules[_address].push(VestingRule({ 
      aces: _aces,
      unlockTime: _unlockTime,
      processed: false
    }));
    lockedAces[_address] = lockedAces[_address].add(_aces);
  }
  function _processVestingRules(address _address) internal {
    for (uint256 i = uint256(0); i < vestingRules[_address].length; i++) {
      if (vestingRules[_address][i].processed == false && vestingRules[_address][i].unlockTime < _now()) {
        lockedAces[_address] = lockedAces[_address].sub(vestingRules[_address][i].aces);
        vestingRules[_address][i].processed = true;
      }
    }
  }
  function _now() internal view returns (uint256) {
    return block.timestamp;
  }
}
