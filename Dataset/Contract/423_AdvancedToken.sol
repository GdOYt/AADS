contract AdvancedToken is PausableToken {
    string public name = "Thailand Tourism Chain";
    string public symbol = "THTC";
    string public version = '3.0.0';
    uint8 public decimals = 18;
    function AdvancedToken() {
      totalSupply = 9 * 10000 * 10000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;    
    }
    function () external payable {
        revert();
    }
}
