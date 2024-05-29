contract HiBTCToken is PausableToken {
    string public name = "HiBTCToken";
    string public symbol = "HIBT";
    string public version = '1.0.0';
    uint8 public decimals = 18;
    function HiBTCToken() {
      totalSupply = 10000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;
    }
    function () {
        revert();
    }
}
