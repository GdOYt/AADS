contract WinEToken is MintableToken, BurnableToken {
    string public constant name = "Win ETH and BTC GAMES";
    string public constant symbol = "WinE";
    uint8 public constant decimals = 18;
    function WinEToken() public {
        totalSupply = 1000000000 ether;
        balances[msg.sender] = totalSupply;
    }
}
