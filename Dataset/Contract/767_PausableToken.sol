contract PausableToken is StandardToken, AdminManager {
    event SetPause(bool isPause);
    bool public paused = true;
    modifier whenNotPaused() {
        if(paused) {
            require(msg.sender == owner || admins[msg.sender]);
        }
        _;
    }
    function setPause(bool _isPause) onlyAdmins public {
        require(paused != _isPause);
        paused = _isPause;
        emit SetPause(_isPause);
    }
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }
    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }
    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
