contract RedpacketVaultV2 {
    using SafeMath for uint256;
    ERC20Interface private erc20;
    address public erc20Address;
    uint256 public totalAmount = 0;  
    uint256 public totalBalance = 0;  
    struct Commitment {                      
        uint256         status;              
        uint256         amount;              
        address payable sender;              
        uint256         timestamp;           
        string          memo;                
        address[]       takenAddresses;      
        uint256         withdrawTimes;
        uint256         cliff;
    }
    mapping(bytes32 => Commitment) private commitments; 
    mapping(address => bytes32[]) private hashKeys;
    address public operator;
    address public redpacketManagerAddress;
    modifier onlyOperator {
        require(msg.sender == operator, "Only operator can call this function.");
        _;
    }
    modifier onlyRedpacketManager {
        require(msg.sender == redpacketManagerAddress, "Only redpacket manager contract can call this function.");
        _;
    }
    constructor(address _erc20Address) public {
        operator = msg.sender;
        erc20Address = _erc20Address;
        erc20 = ERC20Interface(erc20Address);
    }
    function setStatus(bytes32 _hashkey, uint256 _status) external onlyRedpacketManager {
        commitments[_hashkey].status = _status;
    }
    function setAmount(bytes32 _hashkey, uint256 _amount) external onlyRedpacketManager {
        commitments[_hashkey].amount = _amount;
    }
    function setSender(bytes32 _hashkey, address payable _sender) external onlyRedpacketManager {
        commitments[_hashkey].sender = _sender;
        if(hashKeys[_sender].length == 0) hashKeys[_sender] = new bytes32[](0);
        hashKeys[_sender].push(_hashkey);
    }
    function setTimestamp(bytes32 _hashkey, uint256 _timestamp) external onlyRedpacketManager {
        commitments[_hashkey].timestamp = _timestamp;
    }
    function setMemo(bytes32 _hashkey, string calldata _memo) external onlyRedpacketManager {
        commitments[_hashkey].memo = _memo;
    }
    function setWithdrawTimes(bytes32 _hashkey, uint256 _times) external onlyRedpacketManager {
        commitments[_hashkey].withdrawTimes = _times;
    }
    function setCliff(bytes32 _hashkey, uint256 _cliff) external onlyRedpacketManager {
        commitments[_hashkey].cliff = _cliff;
    }
    function initTakenAddresses(bytes32 _hashkey) external onlyRedpacketManager {
        commitments[_hashkey].takenAddresses = new address[](0);
    }
    function isTaken(bytes32 _hashkey, address _address) external view returns(bool) {
        bool has = false;
        for(uint256 i = 0; i < commitments[_hashkey].takenAddresses.length; i++) {
            if(_address == commitments[_hashkey].takenAddresses[i]) {has = true; break;}
        }
        return has;
    }
    function addTakenAddress(bytes32 _hashkey, address _address) external onlyRedpacketManager {
        commitments[_hashkey].takenAddresses.push(_address);
    }
    function getHashkeysBySender() external view returns(bytes32[] memory) {
        bytes32[] memory hashkeys = new bytes32[](hashKeys[msg.sender].length);
        for(uint256 i = 0; i < hashKeys[msg.sender].length; i++) {
            if(this.getAmount(hashKeys[msg.sender][i]) == 0) continue;
            hashkeys[i] = hashKeys[msg.sender][i];
        }
        return hashkeys;
    }
    function getStatus(bytes32 _hashkey) external view onlyRedpacketManager returns(uint256) {
        return commitments[_hashkey].status;
    }
    function getAmount(bytes32 _hashkey) external view returns(uint256) {
        return commitments[_hashkey].amount;
    }
    function getSender(bytes32 _hashkey) external view onlyRedpacketManager returns(address payable) {
        return commitments[_hashkey].sender;
    }
    function getTimestamp(bytes32 _hashkey) external view onlyRedpacketManager returns(uint256) {
        return commitments[_hashkey].timestamp;
    }
    function getMemo(bytes32 _hashkey) external view onlyRedpacketManager returns(string memory) {
        return commitments[_hashkey].memo;
    }
    function getWithdrawTimes(bytes32 _hashkey) external view onlyRedpacketManager returns(uint256) {
        return commitments[_hashkey].withdrawTimes;
    }
    function getCliff(bytes32 _hashkey) external view onlyRedpacketManager returns(uint256) {
        return commitments[_hashkey].cliff;
    }
    function updateOperator(address _operator) external onlyOperator {
        operator = _operator;
    }
    function updateRedpacketManagerAddress(address _redpacketManager, uint256 _allowance) external onlyOperator returns(bool) {
        redpacketManagerAddress = _redpacketManager;
        safeApprove(erc20Address, _redpacketManager, _allowance);
        return true;
    }
    function getRedpacketAllowance() external view returns(uint256) {
      return erc20.allowance(address(this), redpacketManagerAddress);
    }
    function addTotalAmount(uint256 _amount) external onlyRedpacketManager {
        totalAmount = totalAmount.add(_amount);
    }
    function addTotalBalance(uint256 _amount) external onlyRedpacketManager {
        totalBalance = totalBalance.add(_amount);
    }
    function subTotalBalance(uint256 _amount) external onlyRedpacketManager {
        totalBalance = totalBalance.sub(_amount);
    }
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
}
