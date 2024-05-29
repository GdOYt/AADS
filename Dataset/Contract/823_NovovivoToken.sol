contract NovovivoToken is DetailedStandardToken, Ownable {
    constructor() DetailedStandardToken("Novovivo Token Test", "NVT", 18) public {
        totalSupply_ = 8 * 10**9 * 10**uint256(decimals);
        balances[address(this)] = totalSupply_;
    }
    function send(address _to, uint256 _value) onlyOwner public returns (bool) {
        uint256 value = _value.mul(10 ** uint256(decimals));
        ERC20 token;
        token = ERC20(address(this));
        return token.transfer(_to, value);
    }
    function stopTest() onlyOwner public {
        selfdestruct(owner);
    }
    function () external {
        revert();
    }
}
