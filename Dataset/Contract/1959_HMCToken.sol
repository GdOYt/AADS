contract HMCToken is PausableFrozenToken {
    string public name = "HMC";
    string public symbol = "HMC";
    uint8 public decimals = 18;
    function HMCToken() {
      totalSupply = 1000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;    
    }
    function () {
        revert();
    }
}
