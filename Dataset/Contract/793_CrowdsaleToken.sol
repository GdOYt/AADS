contract CrowdsaleToken is ReleasableToken, MintableToken, UpgradeableToken {
  event UpdatedTokenInformation(string newName, string newSymbol);
  string public name;
  string public symbol;
  uint public decimals;
  function CrowdsaleToken(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable) public
    UpgradeableToken(msg.sender) {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    totalSupply_ = _initialSupply;
    decimals = _decimals;
    balances[owner] = totalSupply_;
    if(totalSupply_ > 0) {
      Minted(owner, totalSupply_);
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
  function canUpgrade() public constant returns(bool) {
    return released;
  }
  function setTokenInformation(string _name, string _symbol) public onlyOwner {
    name = _name;
    symbol = _symbol;
    UpdatedTokenInformation(name, symbol);
  }
}
