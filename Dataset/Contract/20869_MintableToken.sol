contract MintableToken is StandardToken, Ownable {
  bool public mintingFinished = false;
  mapping (address => bool) public mintAgents;
  event MintingAgentChanged(address addr, bool state  );
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  modifier onlyMintAgent() {
    if(!mintAgents[msg.sender]) {
        revert();
    }
    _;
  }
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    MintingAgentChanged(addr, state);
  }
  function mint(address _to, uint256 _amount) onlyMintAgent canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
	Transfer(address(0), _to, _amount);
    return true;
  }
  function finishMinting() onlyMintAgent public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
