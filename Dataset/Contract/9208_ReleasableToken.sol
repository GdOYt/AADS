contract ReleasableToken is ERC20, Ownable {
  address public releaseAgent;
  bool public released = false;
  mapping (address => bool) public transferAgents;
  modifier canTransfer(address _sender) {
    if(!released) {
        if(!transferAgents[_sender]) {
            revert();
        }
    }
    _;
  }
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
    releaseAgent = addr;
  }
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    transferAgents[addr] = state;
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
  modifier onlyReleaseAgent() {
    if(msg.sender != releaseAgent) {
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
