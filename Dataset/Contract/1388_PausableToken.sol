contract PausableToken is StandardToken, Controlled {
    function transfer(address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public transferAllowed(msg.sender) returns (bool) {
        return super.approve(_spender, _value);
    }
}
