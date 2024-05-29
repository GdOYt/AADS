contract BurnableToken is StandardToken,Ownable {
    event Burn(address indexed burner, uint256 value);
    function burn(uint256 _value)  onlyOwner public  returns (bool) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = safeSub(balances[burner], _value);
        totalSupply = safeSub(totalSupply, _value);
        emit Burn(burner, _value);
        return true;
    }
}
