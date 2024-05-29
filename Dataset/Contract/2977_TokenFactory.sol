contract TokenFactory {
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        string _tokenSymbol
        ) public returns (LedToken) {
        LedToken newToken = new LedToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _tokenSymbol
        );
        newToken.transferControl(msg.sender);
        return newToken;
    }
}
