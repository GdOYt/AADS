contract MintableToken is PausableToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  bool public mintingFinished = false;
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  address public saleAgent = address(0);
  address public saleAgent2 = address(0);
  function setSaleAgent(address newSaleAgent) onlyOwner public {
    saleAgent = newSaleAgent;
  }
  function setSaleAgent2(address newSaleAgent) onlyOwner public {
    saleAgent2 = newSaleAgent;
  }
  function mint(address _to, uint256 _amount) canMint public returns (bool) {
    require(msg.sender == saleAgent || msg.sender == saleAgent2 || msg.sender == owner);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(this), _to, _amount);
    return true;
  }   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}
