contract Ownable {
  address public owner;
  address public newOwner;
  address public techSupport;
  address public newTechSupport;
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  modifier onlyTechSupport() {
    require(msg.sender == techSupport || msg.sender == owner);
    _;
  }
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }
  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }
  function transferTechSupport (address _newSupport) public{
    require (msg.sender == owner || msg.sender == techSupport);
    newTechSupport = _newSupport;
  }
  function acceptSupport() public{
    if(msg.sender == newTechSupport){
      techSupport = newTechSupport;
    }
  }
}
