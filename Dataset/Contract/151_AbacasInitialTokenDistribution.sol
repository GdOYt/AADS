contract AbacasInitialTokenDistribution is InitialTokenDistribution {
    uint256 public reservedTokensFutureSale;
    uint256 public reservedTokensCommunity;
    uint256 public reservedTokensFoundation;
    uint256 public reservedTokensFounders;
    uint256 public reservedTokensPublicPrivateSale;
    address public futureSaleWallet;
    address public communityWallet;
    address public foundationWallet;
    address public foundersWallet;
    address public publicPrivateSaleWallet;
    uint256 foundersLockStartTime;
    uint256 foundersLockPeriod;
    function AbacasInitialTokenDistribution(
        DetailedERC20 _token,
        address _futureSaleWallet,
        address _communityWallet,
        address _foundationWallet,
        address _foundersWallet,
        address _publicPrivateSaleWallet,
        uint256 _foundersLockStartTime,
        uint256 _foundersLockPeriod
    )
        public
        InitialTokenDistribution(_token)
    {
        futureSaleWallet = _futureSaleWallet;
        communityWallet = _communityWallet;
        foundationWallet = _foundationWallet;
        foundersWallet = _foundersWallet;
        publicPrivateSaleWallet = _publicPrivateSaleWallet;
        foundersLockStartTime = _foundersLockStartTime;
        foundersLockPeriod = _foundersLockPeriod;
        uint8 decimals = _token.decimals();
        reservedTokensFutureSale = 45e6 * (10 ** uint256(decimals));
        reservedTokensCommunity = 10e6 * (10 ** uint256(decimals));
        reservedTokensFoundation = 10e6 * (10 ** uint256(decimals));
        reservedTokensFounders = 5e6 * (10 ** uint256(decimals));
        reservedTokensPublicPrivateSale = 30e6 * (10 ** uint256(decimals));
    }
    function initialDistribution() internal {
        initialTransfer(futureSaleWallet, reservedTokensFutureSale);
        initialTransfer(communityWallet, reservedTokensCommunity);
        initialTransfer(foundationWallet, reservedTokensFoundation);
        initialTransfer(publicPrivateSaleWallet, reservedTokensPublicPrivateSale);
        lock(foundersWallet, reservedTokensFounders, foundersLockStartTime + foundersLockPeriod);
    }
    function totalTokensDistributed() view public returns (uint256) {
        return reservedTokensFutureSale + reservedTokensCommunity + reservedTokensFoundation + reservedTokensFounders + reservedTokensPublicPrivateSale;
    }
}
