contract CABoxToken is BurnableToken, Ownable {
    string public constant name = "CABox";
    string public constant symbol = "CAB";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 500 * 1000000 * (10 ** uint256(decimals));
    function CABoxToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
