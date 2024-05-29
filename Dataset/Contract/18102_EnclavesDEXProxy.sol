contract EnclavesDEXProxy is StorageConsumer {
  using KindMath for uint256;
  address public admin;  
  address public feeAccount;  
  struct EtherDeltaInfo {
    uint256 feeMake;
    uint256 feeTake;
  }
  EtherDeltaInfo public etherDeltaInfo;
  uint256 public feeTake;  
  uint256 public feeAmountThreshold;  
  address public etherDelta;
  bool public useEIP712 = true;
  bytes32 public tradeABIHash;
  bytes32 public withdrawABIHash;
  bool freezeTrading;
  bool depositTokenLock;
  mapping (address => mapping (uint256 => bool)) nonceCheck;
  mapping (address => mapping (address => uint256)) public tokens;  
  mapping (address => mapping (bytes32 => bool)) public orders;  
  mapping (address => mapping (bytes32 => uint256)) public orderFills;  
  address internal implementation;
  address public proposedImplementation;
  uint256 public proposedTimestamp;
  event Upgraded(address _implementation);
  event UpgradedProposed(address _proposedImplementation, uint256 _proposedTimestamp);
  modifier onlyAdmin {
    require(msg.sender == admin);
    _;
  }
  function EnclavesDEXProxy(address _storageAddress, address _implementation, address _admin, address _feeAccount, uint256 _feeTake, uint256 _feeAmountThreshold, address _etherDelta, bytes32 _tradeABIHash, bytes32 _withdrawABIHash) public
    StorageConsumer(_storageAddress)
  {
    require(_implementation != address(0));
    implementation = _implementation;
    admin = _admin;
    feeAccount = _feeAccount;
    feeTake = _feeTake;
    feeAmountThreshold = _feeAmountThreshold;
    etherDelta = _etherDelta;
    tradeABIHash = _tradeABIHash;
    withdrawABIHash = _withdrawABIHash;
    etherDeltaInfo.feeMake = EtherDeltaI(etherDelta).feeMake();
    etherDeltaInfo.feeTake = EtherDeltaI(etherDelta).feeTake();
  }
  function getImplementation() public view returns(address) {
    return implementation;
  }
  function proposeUpgrade(address _proposedImplementation) public onlyAdmin {
    require(implementation != _proposedImplementation);
    require(_proposedImplementation != address(0));
    proposedImplementation = _proposedImplementation;
    proposedTimestamp = now + 2 weeks;
    UpgradedProposed(proposedImplementation, now);
  }
  function upgrade() public onlyAdmin {
    require(proposedImplementation != address(0));
    require(proposedTimestamp < now);
    implementation = proposedImplementation;
    Upgraded(implementation);
  }
  function () payable public {
    bytes memory data = msg.data;
    address impl = getImplementation();
    assembly {
      let result := delegatecall(gas, impl, add(data, 0x20), mload(data), 0, 0)
      let size := returndatasize
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)
      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}
