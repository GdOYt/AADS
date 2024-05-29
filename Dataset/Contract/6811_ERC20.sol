contract ERC20 {
  bool public paused = false;
  bool public mintingFinished = false;
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) internal allowed;
  uint256 totalSupply_;
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function allowance(address _owner, address spender) public view returns (uint256);
  function increaseApproval(address spender, uint addedValue) public returns (bool);
  function decreaseApproval(address spender, uint subtractedValue) public returns (bool);
  modifier canMint() {
    require(!mintingFinished);
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
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Buy(address indexed _recipient, uint _amount);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Pause();
  event Unpause();
}
