contract AssetWithRevert is Asset {
    modifier validateBalance(address _from, uint _value) {
        require(proxy.balanceOf(_from) >= _value, 'Insufficient balance');
        _;
    }
    modifier validateAllowance(address _from, address _spender, uint _value) {
        require(proxy.allowance(_from, _spender) >= _value, 'Insufficient allowance');
        _;
    }
    function _transferWithReference(address _to, uint _value, string _reference, address _sender)
        internal
        validateBalance(_sender, _value)
        returns(bool)
    {
        return super._transferWithReference(_to, _value, _reference, _sender);
    }
    function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference, address _sender)
        internal
        validateBalance(_sender, _value)
        returns(bool)
    {
        return super._transferToICAPWithReference(_icap, _value, _reference, _sender);
    }
    function _transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender)
        internal
        validateBalance(_from, _value)
        validateAllowance(_from, _sender, _value)
        returns(bool)
    {
        return super._transferFromWithReference(_from, _to, _value, _reference, _sender);
    }
    function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference, address _sender)
        internal
        validateBalance(_from, _value)
        validateAllowance(_from, _sender, _value)
        returns(bool)
    {
        return super._transferFromToICAPWithReference(_from, _icap, _value, _reference, _sender);
    }
}
