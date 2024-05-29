contract HCPTToken is UnboundedRegularToken {
    uint public totalSupply = 60*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "Hash Computing Power Token";
    string constant public symbol = "HCPT";
    function HCPTToken() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}
