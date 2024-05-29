contract PausableToken is StandardToken, Pausable {
    address public allowedTransferWallet;
    constructor(address _allowedTransferWallet) public {
        allowedTransferWallet = _allowedTransferWallet;
    }
    modifier whenNotPausedOrOwnerOrAllowed() {
        require(!paused || msg.sender == owner || msg.sender == allowedTransferWallet);
        _;
    }
    function changeAllowTransferWallet(address _allowedTransferWallet) public onlyOwner {
        allowedTransferWallet = _allowedTransferWallet;
    }
    function transfer(address _to, uint256 _value) public whenNotPausedOrOwnerOrAllowed returns (bool) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPausedOrOwnerOrAllowed returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}
