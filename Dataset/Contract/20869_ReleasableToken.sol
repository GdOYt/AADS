contract ReleasableToken is ERC20, Ownable {
  address public releaseAgent;
  bool public released = false;
  mapping (address => bool) public transferAgents;
  mapping(address => uint) public lock_addresses;
  event AddLockAddress(address addr, uint lock_time);  
  modifier canTransfer(address _sender) {
    if(!released) {
        if(!transferAgents[_sender]) {
            revert();
        }
    }
	else {
		if(now < lock_addresses[_sender]) {
			revert();
		}
	}
    _;
  }
  function ReleasableToken() {
	releaseAgent = msg.sender;
  }
  function addLockAddressInternal(address addr, uint lock_time) inReleaseState(false) internal {
	if(addr == 0x0) revert();
	lock_addresses[addr]= lock_time;
	AddLockAddress(addr, lock_time);
  }
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
    releaseAgent = addr;
  }
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    transferAgents[addr] = state;
  }
  modifier onlyReleaseAgent() {
    if(msg.sender != releaseAgent) {
        revert();
    }
    _;
  }
  function releaseTokenTransfer() public onlyReleaseAgent {
    released = true;
  }
  modifier inReleaseState(bool releaseState) {
    if(releaseState != released) {
        revert();
    }
    _;
  }  
  function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
   return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }
}
