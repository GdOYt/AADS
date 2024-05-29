contract CmmToken is PausableToken {
    string public name = "CustomerMarketingManagement";
    string public symbol = "CMM";
    string public version = '1.0.0';
    uint8 public decimals = 2;
    function CmmToken() {
      totalSupply = 1800000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;    
    }
    function () {
        revert();
    }
}
