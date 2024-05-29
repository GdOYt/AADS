contract BurnableToken is StandardToken {
    event Burn(address indexed _from, uint256 _value);
    function burn(uint256 _value) public {
        require(_value != 0);
        address burner = msg.sender;
        require(_value <= balances[burner]);
        balances[burner] = balances[burner].minus(_value);
        totalSupply = totalSupply.minus(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
}
