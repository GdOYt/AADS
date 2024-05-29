contract WithdrawFromKickTheCoin {
    address public owner;
    address public ktcAddress;
    bool public ktcAddressIsSet;
    function WithdrawFromKickTheCoin()
    public
    {
        owner = msg.sender;
        ktcAddressIsSet = false;
    }
    function setKtcAddress(address _ktcAddress, bool isImmutable)
    public
    {
        require(!ktcAddressIsSet);
        ktcAddressIsSet = isImmutable;
        ktcAddress = _ktcAddress;
    }
    function getKtcAddress()
    public
    constant
    returns (address)
    {
        return ktcAddress;
    }
    function getOwner()
    public
    constant
    returns (address)
    {
        return owner;
    }
    function release()
    public
    {
        owner.transfer(this.balance);
    }
    function()
    public
    {
        KickTheCoin ktc = KickTheCoin(ktcAddress);
        ktc.pullShares(msg.sender);
    }
}
