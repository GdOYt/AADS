contract TokenFactoryInterface {
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        string _tokenSymbol
      ) public returns (LedToken newToken);
}
