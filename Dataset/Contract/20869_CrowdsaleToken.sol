contract CrowdsaleToken is ReleasableToken, MintableToken {
  string public name;
  string public symbol;
  uint public decimals;
  function CrowdsaleToken(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable) {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    totalSupply_ = _initialSupply;
    decimals = _decimals;
    balances[owner] = totalSupply_;
    if(totalSupply_ > 0) {
      Mint(owner, totalSupply_);
    }
    if(!_mintable) {
      mintingFinished = true;
      if(totalSupply_ == 0) {
        revert();  
      }
    }
  }
  function releaseTokenTransfer() public onlyReleaseAgent {
    mintingFinished = true;
    super.releaseTokenTransfer();
  }
  function addLockAddress(address addr, uint lock_time) onlyMintAgent inReleaseState(false) public {
	super.addLockAddressInternal(addr, lock_time);
  }
}
