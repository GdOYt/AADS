contract CrowdsaleTokenExt is ReleasableToken, MintableTokenExt, UpgradeableToken {
  event UpdatedTokenInformation(string newName, string newSymbol);
  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
  string public name;
  string public symbol;
  uint public decimals;
  uint public minCap;
  function CrowdsaleTokenExt(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable, uint _globalMinCap)
    UpgradeableToken(msg.sender) {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    totalSupply = _initialSupply;
    decimals = _decimals;
    minCap = _globalMinCap;
    balances[owner] = totalSupply;
    if(totalSupply > 0) {
      Minted(owner, totalSupply);
    }
    if(!_mintable) {
      mintingFinished = true;
      if(totalSupply == 0) {
        throw;  
      }
    }
  }
  function releaseTokenTransfer() public onlyReleaseAgent {
    mintingFinished = true;
    super.releaseTokenTransfer();
  }
  function canUpgrade() public constant returns(bool) {
    return released && super.canUpgrade();
  }
  function setTokenInformation(string _name, string _symbol) onlyOwner {
    name = _name;
    symbol = _symbol;
    UpdatedTokenInformation(name, symbol);
  }
  function claimTokens(address _token) public onlyOwner {
    require(_token != address(0));
    ERC20 token = ERC20(_token);
    uint balance = token.balanceOf(this);
    token.transfer(owner, balance);
    ClaimedTokens(_token, owner, balance);
  }
}
