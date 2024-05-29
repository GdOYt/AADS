contract BlockFollowInitialTokenDistribution is InitialTokenDistribution {
    uint256 public reservedTokensFunctionality;
    uint256 public reservedTokensTeam;
    address functionalityWallet;
    address teamWallet;
    constructor(
        DetailedERC20 _token,
        address _functionalityWallet,
        address _teamWallet
    )
    public
    InitialTokenDistribution(_token)
    {
        functionalityWallet = _functionalityWallet;
        teamWallet = _teamWallet;
        uint8 decimals = _token.decimals();
        reservedTokensFunctionality = 80e6 * (10 ** uint256(decimals));
        reservedTokensTeam = 10e6 * (10 ** uint256(decimals));
    }
    function initialDistribution() internal {
        initialTransfer(functionalityWallet, reservedTokensFunctionality);
        initialTransfer(teamWallet, reservedTokensTeam);
    }
    function totalTokensDistributed() public view returns (uint256) {
        return reservedTokensFunctionality + reservedTokensTeam;
    }
}
