contract BurnableToken is StandardToken {
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }
    function _burn(address _holder, uint256 _value) internal {
        require(_value <= balances[_holder]);
        balances[_holder] = balances[_holder].subtract(_value);
        totalSupply = totalSupply.subtract(_value);
        emit Burn(_holder, _value);
        emit Transfer(_holder, address(0), _value);
    }
    event Burn(address indexed _burner, uint256 _value);
}
