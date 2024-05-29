contract LockableToken is PausableToken {
    struct LockData {
        uint256 balance;
        uint256 releaseTimeS;
    }
    event SetLock(address _address, uint256 _lockValue, uint256 _releaseTimeS);
    mapping (address => LockData) public locks;
    modifier whenNotLocked(address _from, uint256 _value) {
        require( activeBalanceOf(_from) >= _value );
        _;
    }
    function activeBalanceOf(address _owner) public view returns (uint256) {
        if( uint256(now) < locks[_owner].releaseTimeS ) {
            return balances[_owner].sub(locks[_owner].balance);
        }
        return balances[_owner];
    }
    function setLock(address _address, uint256 _lockValue, uint256 _releaseTimeS) onlyAdmins public {
        require( uint256(now) > locks[_address].releaseTimeS );
        locks[_address].balance = _lockValue;
        locks[_address].releaseTimeS = _releaseTimeS;
        emit SetLock(_address, _lockValue, _releaseTimeS);
    }
    function transfer(address _to, uint256 _value) public whenNotLocked(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotLocked(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}
