contract WithdrawFromKickTheCoin {
    address owner;
    address ktcAddress;
    modifier onlyBy(address _account)
    {
        require(msg.sender == _account);
        _;
    }
    function WithdrawFromKickTheCoin()
    public
    {
        owner = msg.sender;
    }
    function setKtcAddress(address _ktcAddress)
    public
    onlyBy(owner)
    {
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
