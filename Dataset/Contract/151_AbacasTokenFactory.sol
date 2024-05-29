contract AbacasTokenFactory {
    uint256 constant public FOUNDERS_LOCK_START_TIME  = 1541030400;
    uint256 constant public FOUNDERS_LOCK_PERIOD  = 90 days;
    AbacasToken public token;
    InitialTokenDistribution public initialDistribution;
    function create(
        address _allowedToTransferWallet,
        address _futureSaleWallet,
        address _communityWallet,
        address _foundationWallet,
        address _foundersWallet,
        address _publicPrivateSaleWallet
    ) public
    {
        token = new AbacasToken(_allowedToTransferWallet);
        initialDistribution = new AbacasInitialTokenDistribution(token, _futureSaleWallet, _communityWallet, _foundationWallet, _foundersWallet, _publicPrivateSaleWallet, FOUNDERS_LOCK_START_TIME, FOUNDERS_LOCK_PERIOD);
        token.approve(initialDistribution, token.balanceOf(this));
        initialDistribution.processInitialDistribution();
        token.pause();
        transfer();
    }
    function transfer() private {
        token.transferOwnership(msg.sender);
        initialDistribution.transferOwnership(msg.sender);
    }
}
