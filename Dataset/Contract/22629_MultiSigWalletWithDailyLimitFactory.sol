contract MultiSigWalletWithDailyLimitFactory is Factory {
    function create(address[] _owners, uint _required, uint _dailyLimit)
        public
        returns (address wallet)
    {
        wallet = new MultiSigWalletWithDailyLimit(_owners, _required, _dailyLimit);
        register(wallet);
    }
}
