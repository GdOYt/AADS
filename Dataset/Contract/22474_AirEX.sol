contract AirEX is MintableToken {
  string public constant name = "AIRX";
  string public constant symbol = "AIRX";
  uint8 public constant decimals = 18;
  uint256 public hardCap;
  uint256 public softCap;
  function AirEX(uint256 _cap) public {
    require(_cap > 0);
    hardCap = _cap;
  }
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply_.add(_amount) <= hardCap);
    return super.mint(_to, _amount);
  }
  function updateHardCap(uint256 _cap) onlyOwner public {
    require(_cap > 0);
    hardCap = _cap;
  }
  function updateSoftCap(uint256 _cap) onlyOwner public {
    require(_cap > 0);
    softCap = _cap;  
  }
}
