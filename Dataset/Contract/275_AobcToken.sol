contract AobcToken is StandardToken {
    uint public totalSupply = 100*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "Aobc Token";
    string constant public symbol = "AOT";
    function AobcToken() public {
        balances[msg.sender] = totalSupply;
    }
}
