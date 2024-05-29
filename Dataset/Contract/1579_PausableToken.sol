contract PausableToken is StandardToken, Pausable {
    function transfer(address _to, uint _value) whenNotPaused {
        super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) whenNotPaused {
        super.transferFrom(_from, _to, _value);
    }
}
