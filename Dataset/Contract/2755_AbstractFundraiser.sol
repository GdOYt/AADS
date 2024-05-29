contract AbstractFundraiser {
    ERC20Token public token;
    event FundsReceived(address indexed _address, uint _ethers, uint _tokens);
    function initializeFundraiserToken(address _token) internal
    {
        token = ERC20Token(_token);
    }
    function() public payable {
        receiveFunds(msg.sender, msg.value);
    }
    function getConversionRate() public view returns (uint256);
    function hasEnded() public view returns (bool);
    function receiveFunds(address _address, uint256 _amount) internal;
    function validateTransaction() internal view;
    function handleTokens(address _address, uint256 _tokens) internal;
    function handleFunds(address _address, uint256 _ethers) internal;
}
