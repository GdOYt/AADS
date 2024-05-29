contract IPM is StandardToken ,Ownable {
  string public constant name = "IPMCOIN";
  string public constant symbol = "IPM";
  uint256 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 3000000000 * 10 ** uint256(decimals);
  function IPM() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    owner=msg.sender;
  }
  function Airdrop(ERC20 token, address[] _addresses, uint256 amount) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            token.transfer(_addresses[i], amount);
        }
    }
}
