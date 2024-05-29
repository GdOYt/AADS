contract Lara is DetailedERC20, StandardToken, BurnableToken, PausableToken {
    function Lara(
        uint256 totalSupply
    ) DetailedERC20(
        "Lara",
        "LARA",
        8
    ) {
        totalSupply_ = totalSupply;
        balances[msg.sender] = totalSupply;
    }
}
