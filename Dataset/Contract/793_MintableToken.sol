contract MintableToken is StandardTokenExt, Ownable {
  using SafeMathLib for uint;
  bool public mintingFinished = false;
  mapping (address => bool) public mintAgents;
  event MintingAgentChanged(address addr, bool state);
  event Minted(address receiver, uint amount);
  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply_ = totalSupply_.plus(amount);
    balances[receiver] = balances[receiver].plus(amount);
    Transfer(0, receiver, amount);
  }
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    MintingAgentChanged(addr, state);
  }
  modifier onlyMintAgent() {
    if(!mintAgents[msg.sender]) {
        revert();
    }
    _;
  }
  modifier canMint() {
    if(mintingFinished) revert();
    _;
  }
}
