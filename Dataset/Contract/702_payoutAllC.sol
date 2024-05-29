contract payoutAllC is safeSend {
    address private _payTo;
    event PayoutAll(address payTo, uint value);
    constructor(address initPayTo) public {
        assert(initPayTo != address(0));
        _payTo = initPayTo;
    }
    function _getPayTo() internal view returns (address) {
        return _payTo;
    }
    function _setPayTo(address newPayTo) internal {
        _payTo = newPayTo;
    }
    function payoutAll() external {
        address a = _getPayTo();
        uint bal = address(this).balance;
        doSafeSend(a, bal);
        emit PayoutAll(a, bal);
    }
}
