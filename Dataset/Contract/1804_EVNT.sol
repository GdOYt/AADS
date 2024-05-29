contract EVNT is StandardToken {
  string public constant name = "EVENTICA";
  string public constant symbol = "EVNT";
  uint256 public constant decimals = 8;
  address public owner= 0x5b024117a745df6b31e25ec4a11548e00d52898a;
  uint256 public constant INITIAL_SUPPLY = 30000000000000000;
  function EVNT() {
    totalSupply = INITIAL_SUPPLY;
    balances[owner] = INITIAL_SUPPLY;
  }
  function Airdrop(ERC20 token, address[] _addresses, uint256 amount) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            token.transfer(_addresses[i], amount);
        }
    }
 modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
  function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
