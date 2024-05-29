contract SafeMin {
    modifier onlyHuman {
        if (_isHuman()) {
            _;
        }
    }
    modifier immutable(address _address) {
        if (_address == 0) {
            _;
        }
    }
    function _safeFalse() internal returns(bool) {
        _safeSend(msg.sender, msg.value);
        return false;
    }
    function _safeSend(address _to, uint _value) internal {
        if (!_unsafeSend(_to, _value)) {
            throw;
        }
    }
    function _unsafeSend(address _to, uint _value) internal returns(bool) {
        return _to.call.value(_value)();
    }
    function _isContract() constant internal returns(bool) {
        return msg.sender != tx.origin;
    }
    function _isHuman() constant internal returns(bool) {
        return !_isContract();
    }
}
