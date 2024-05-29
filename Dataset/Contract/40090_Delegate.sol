contract Delegate {
    mapping(address => mapping(address => bool)) public senderDelegates;
    modifier onlyDelegate(address _sender) {
        if (_sender == msg.sender || address(this) == msg.sender || senderDelegates[_sender][msg.sender]) {
            _
        }
    }
    function setDelegate(address _delegate, bool _trust) returns(bool) {
        senderDelegates[msg.sender][_delegate] = _trust;
        return true;
    }
}
