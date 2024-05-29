contract LICToken is UnboundedRegularToken {
    uint public totalSupply = 10*10**27;
    uint8 constant public decimals = 18;
    string constant public name = "LifeCoinToken";
    string constant public symbol = "LIC";
    function LICToken() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}
