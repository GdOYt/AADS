contract Safe {
    modifier noValue {
        if (msg.value > 0) {
            _safeSend(msg.sender, msg.value);
        }
        _
    }
    modifier onlyHuman {
        if (_isHuman()) {
            _
        }
    }
    modifier noCallback {
        if (!isCall) {
            _
        }
    }
    modifier immutable(address _address) {
        if (_address == 0) {
            _
        }
    }
    address stackDepthLib;
    function setupStackDepthLib(address _stackDepthLib) immutable(address(stackDepthLib)) returns(bool) {
        stackDepthLib = _stackDepthLib;
        return true;
    }
    modifier requireStackDepth(uint16 _depth) {
        if (stackDepthLib == 0x0) {
            throw;
        }
        if (_depth > 1023) {
            throw;
        }
        if (!stackDepthLib.delegatecall(0x32921690, stackDepthLib, _depth)) {
            throw;
        }
        _
    }
    function _safeFalse() internal noValue() returns(bool) {
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
    bool private isCall = false;
    function _setupNoCallback() internal {
        isCall = true;
    }
    function _finishNoCallback() internal {
        isCall = false;
    }
}
