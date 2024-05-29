contract IHookOperator is IOwnableUpgradeableImplementation {
    event LogSetBalancePercentageLimit(uint256 limit);
    event LogSetOverBalanceLimitHolder(address holderAddress, bool isHolder);
    event LogSetUserManager(address userManagerAddress);
    event LogSetICOToken(address icoTokenAddress);
    event LogOnTransfer(address from, address to, uint tokens);
    event LogOnMint(address to, uint256 amount);
    event LogOnBurn(uint amount);
    event LogOnTaxTransfer(address indexed taxableUser, uint tokensAmount);
    event LogSetKYCVerificationContract(address _kycVerificationContractAddress);
    event LogUpdateUserRatio(uint256 generationRatio, address indexed userContractAddress);
    function setBalancePercentageLimit(uint256 limit) public;
    function getBalancePercentageLimit() public view returns(uint256);
    function setOverBalanceLimitHolder(address holderAddress, bool isHolder) public;
    function setUserManager(address userManagerAddress) public;
    function getUserManager() public view returns(address userManagerAddress);
    function setICOToken(address icoTokenAddress) public;
    function getICOToken() public view returns(address icoTokenAddress);
    function onTransfer(address from, address to, uint256 tokensAmount) public;
    function onMint(address to, uint256 tokensAmount) public;
    function onBurn(uint256 amount) public;
    function onTaxTransfer(address taxableUser, uint256 tokensAmount) public;
    function kycVerification(address from, address to, uint256 tokensAmount) public;
    function setKYCVerificationContract(address _kycVerificationContractAddress) public;
    function getKYCVerificationContractAddress() public view returns(address _kycVerificationContractAddress);
    function updateUserRatio(uint256 generationRatio, address userContractAddress) public;
    function isOverBalanceLimitHolder(address holderAddress) public view returns(bool);
    function isInBalanceLimit(address userAddress, uint256 tokensAmount) public view returns(bool);
}
