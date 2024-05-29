contract GoToken is StandardToken {
    string constant public name = "GoToken";
    string constant public symbol = "GOT";
    uint256 constant public decimals = 18;
    uint256 constant multiplier = 10 ** (decimals);
    event Deployed(uint256 indexed _total_supply);
    function GoToken(address auction_address, address wallet_address, uint256 initial_supply) public
    {
        require(auction_address != 0x0);
        require(wallet_address != 0x0);
        require(initial_supply > multiplier);
        totalSupply = initial_supply;
        balances[auction_address] = initial_supply / 2;
        balances[wallet_address] = initial_supply / 2;
        Transfer(0x0, auction_address, balances[auction_address]);
        Transfer(0x0, wallet_address, balances[wallet_address]);
        Deployed(totalSupply);
        assert(totalSupply == balances[auction_address] + balances[wallet_address]);
    }
}
