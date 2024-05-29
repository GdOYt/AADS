contract Crowdsale is Pausable, TokenInfo {
  using SafeMath for uint256;
  LedTokenInterface public ledToken;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public totalWeiRaised;
  uint256 public tokensMinted;
  uint256 public totalSupply;
  uint256 public contributors;
  uint256 public surplusTokens;
  bool public finalized;
  bool public ledTokensAllocated;
  address public ledMultiSig = LED_MULTISIG;
  bool public started = false;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event NewClonedToken(address indexed _cloneToken);
  event OnTransfer(address _from, address _to, uint _amount);
  event OnApprove(address _owner, address _spender, uint _amount);
  event LogInt(string _name, uint256 _value);
  event Finalized();
  function forwardFunds() internal {
    ledMultiSig.transfer(msg.value);
  }
  function validPurchase() internal constant returns (bool) {
    uint256 current = now;
    bool presaleStarted = (current >= startTime || started);
    bool presaleNotEnded = current <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return nonZeroPurchase && presaleStarted && presaleNotEnded;
  }
  function totalSupply() public constant returns (uint256) {
    return ledToken.totalSupply();
  }
  function balanceOf(address _owner) public constant returns (uint256) {
    return ledToken.balanceOf(_owner);
  }
  function changeController(address _newController) public onlyOwner {
    require(isContract(_newController));
    ledToken.transferControl(_newController);
  }
  function enableMasterTransfers() public onlyOwner {
    ledToken.enableMasterTransfers(true);
  }
  function lockMasterTransfers() public onlyOwner {
    ledToken.enableMasterTransfers(false);
  }
  function forceStart() public onlyOwner {
    started = true;
  }
  function isContract(address _addr) constant internal returns(bool) {
    uint size;
    if (_addr == 0)
      return false;
    assembly {
        size := extcodesize(_addr)
    }
    return size>0;
  }
  modifier whenNotFinalized() {
    require(!finalized);
    _;
  }
}
