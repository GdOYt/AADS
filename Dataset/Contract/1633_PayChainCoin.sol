contract PayChainCoin is BasicToken {
  string public constant name = "PayChainCoin";
  string public constant symbol = "PCC";
  uint256 public constant decimals = 18;
  constructor() public {
    _assign(0xa3f351bD8A2cB33822DeFE13e0efB968fc22A186, 690);
    _assign(0xd3C72E4D0EAdab0Eb7A4f416b67754185F72A1fa, 10);
    _assign(0x32A2594Ba3af6543E271e5749Dc39Dd85cFbE1e8, 150);
    _assign(0x7c3db3C5862D32A97a53BFEbb34C384a4b52C2Cc, 150);
  }
  function _assign(address _address, uint256 _value) private {
    uint256 amount = _value * (10 ** 6) * (10 ** decimals);
    balances[_address] = amount;
    totalSupply = totalSupply.add(amount);
  }
}
