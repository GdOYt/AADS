contract AIToken is PausableToken {
    string public name = 'AIToken';
    string public symbol = 'AIToken';
    string public version = '1.0.1';
    uint8 public decimals = 18;
    function AIToken(uint256 initialSupply) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }
    function () {
        revert();
    }
}
