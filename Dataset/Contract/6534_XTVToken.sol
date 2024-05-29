contract XTVToken is XTVNetworkGuard, ERC20Token {
  using SafeMath for uint256;
  string public constant name = "XTV";
  string public constant symbol = "XTV";
  uint public constant decimals = 18;
  address public fullfillTeamAddress;
  address public fullfillFounder;
  address public fullfillAdvisors;
  address public XTVNetworkContractAddress;
  bool public airdropActive;
  uint public startTime;
  uint public endTime;
  uint public XTVAirDropped;
  uint public XTVBurned;
  mapping(address => bool) public claimed;
  uint256 private constant TOKEN_MULTIPLIER = 1000000;
  uint256 private constant DECIMALS = 10 ** decimals;
  uint256 public constant INITIAL_SUPPLY = 500 * TOKEN_MULTIPLIER * DECIMALS;
  uint256 public constant EXPECTED_TOTAL_SUPPLY = 1000 * TOKEN_MULTIPLIER * DECIMALS;
  uint256 public constant ALLOC_TEAM = 330 * TOKEN_MULTIPLIER * DECIMALS;
  uint256 public constant ALLOC_ADVISORS = 70 * TOKEN_MULTIPLIER * DECIMALS;
  uint256 public constant ALLOC_FOUNDER = 100 * TOKEN_MULTIPLIER * DECIMALS;
  uint256 public constant ALLOC_AIRDROP = 500 * TOKEN_MULTIPLIER * DECIMALS;
  uint256 public constant AIRDROP_CLAIM_AMMOUNT = 500 * DECIMALS;
  modifier isAirdropActive() {
    require(airdropActive);
    _;
  }
  modifier canClaimTokens() {
    uint256 remainingSupply = balances[address(0)];
    require(!claimed[msg.sender] && remainingSupply > AIRDROP_CLAIM_AMMOUNT);
    _;
  }
  constructor(
    address _fullfillTeam,
    address _fullfillFounder,
    address _fullfillAdvisors
  ) public {
    owner = msg.sender;
    fullfillTeamAddress = _fullfillTeam;
    fullfillFounder = _fullfillFounder;
    fullfillAdvisors = _fullfillAdvisors;
    airdropActive = true;
    startTime = block.timestamp;
    endTime = startTime + 365 days;
    balances[_fullfillTeam] = ALLOC_TEAM;
    balances[_fullfillFounder] = ALLOC_FOUNDER;
    balances[_fullfillAdvisors] = ALLOC_ADVISORS;
    balances[address(0)] = ALLOC_AIRDROP;
    totalSupply_ = EXPECTED_TOTAL_SUPPLY;
    emit Transfer(address(this), address(0), ALLOC_AIRDROP);
  }
  function setXTVNetworkEndorser(address _addr, bool isEndorser) public onlyOwner {
    xtvNetworkEndorser[_addr] = isEndorser;
  }
  function claim(
    string memory token,
    bytes32 verificationHash,
    bytes memory xtvSignature
  ) 
    public
    isAirdropActive
    canClaimTokens
    validateSignature(token, verificationHash, xtvSignature)
    returns (uint256)
  {
    claimed[msg.sender] = true;
    balances[address(0)] = balances[address(0)].sub(AIRDROP_CLAIM_AMMOUNT);
    balances[msg.sender] = balances[msg.sender].add(AIRDROP_CLAIM_AMMOUNT);
    XTVAirDropped = XTVAirDropped.add(AIRDROP_CLAIM_AMMOUNT);
    emit Transfer(address(0), msg.sender, AIRDROP_CLAIM_AMMOUNT);
    return balances[msg.sender];
  }
  function burnTokens() public onlyOwner {
    require(block.timestamp > endTime);
    uint256 remaining = balances[address(0)];
    airdropActive = false;
    XTVBurned = remaining;
  }
  function setXTVNetworkContractAddress(address addr) public onlyOwner {
    XTVNetworkContractAddress = addr;
  }
  function setXTVTokenAirdropStatus(bool _status) public onlyOwner {
    airdropActive = _status;
  }
}
