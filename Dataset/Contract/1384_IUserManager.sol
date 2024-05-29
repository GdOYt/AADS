contract IUserManager is IOwnableUpgradeableImplementation {
    event LogSetDataContract(address _dataContractAddress);
    event LogSetTaxPercentage(uint256 _taxPercentage);
    event LogSetTaxationPeriod(uint256 _taxationPeriod);
    event LogSetUserFactoryContract(address _userFactoryContract);
    event LogSetHookOperatorContract(address _HookOperatorContract);
    event LogUpdateGenerationRatio(uint256 _generationRatio, address userContractAddress);
    event LogUpdateLastTransactionTime(address _userAddress);
    event LogUserAsFounderMark(address userAddress);
    function setDataContract(address _dataContractAddress) public;
    function getDataContractAddress() public view returns(address _dataContractAddress);
    function setTaxPercentage(uint256 _taxPercentage) public;
    function setTaxationPeriod(uint256 _taxationPeriod) public;
    function setUserFactoryContract(address _userFactoryContract) public;
    function getUserFactoryContractAddress() public view returns(address _userFactoryContractAddress);
    function setHookOperatorContract(address _HookOperatorContract) public;
    function getHookOperatorContractAddress() public view returns(address _HookOperatorContractAddress);
    function isUserKYCVerified(address _userAddress) public view returns(uint256 KYCStatus);
    function isBlacklisted(address _userAddress) public view returns(bool _isBlacklisted);
    function isBannedUser(address userAddress) public view returns(bool _isBannedUser);
    function updateGenerationRatio(uint256 _generationRatio, address userContractAddress) public;
    function updateLastTransactionTime(address _userAddress) public;
    function getUserContractAddress(address _userAddress) public view returns(IUserContract _userContract);
    function isValidUser(address userAddress) public view returns(bool);
    function setCrowdsaleContract(address crowdsaleInstance) external;
    function getCrowdsaleContract() external view returns(address);
    function markUserAsFounder(address userAddress) external;
}
