contract EDUCrowdsale is AllowanceCrowdsale, CappedCrowdsale, TimedCrowdsale, Ownable, Certifiable {
    using SafeMath for uint256;
    uint256 constant FIFTY_ETH = 50 * (10 ** 18);
    uint256 constant HUNDRED_AND_FIFTY_ETH = 150 * (10 ** 18);
    uint256 constant TWO_HUNDRED_AND_FIFTY_ETH = 250 * (10 ** 18);
    uint256 constant TEN_ETH = 10 * (10 ** 18);
    EDUToken public token;
    event TokenWalletChanged(address indexed newTokenWallet);
    event WalletChanged(address indexed newWallet);
    constructor(
        address _wallet,
        EDUToken _token,
        address _tokenWallet,
        uint256 _cap,
        uint256 _openingTime,
        uint256 _closingTime,
        address _certifier
    ) public
      Crowdsale(getCurrentRate(), _wallet, _token)
      AllowanceCrowdsale(_tokenWallet)
      CappedCrowdsale(_cap)
      TimedCrowdsale(_openingTime, _closingTime)
      Certifiable(_certifier)
    {
        token = _token;
    }
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        if (certifier.certified(_beneficiary)) {
            token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
        } else {
            token.delayedTransferFrom(tokenWallet, _beneficiary, _tokenAmount);
        }
    }
    function getCurrentRate() public view returns (uint256) {
        if (block.timestamp < 1528156799) {          
            return 1050;
        } else if (block.timestamp < 1528718400) {   
            return 940;
        } else if (block.timestamp < 1529323200) {   
            return 865;
        } else if (block.timestamp < 1529928000) {   
            return 790;
        } else {
            return 750;
        }
    }
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256)
    {
        uint256 currentRate = getCurrentRate();
        uint256 volumeBonus = _getVolumeBonus(currentRate, _weiAmount);
        return currentRate.mul(_weiAmount).add(volumeBonus);
    }
    function _getVolumeBonus(uint256 _currentRate, uint256 _weiAmount) internal view returns (uint256) {
        if (_weiAmount >= TEN_ETH) {
            return _currentRate.mul(_weiAmount).mul(20).div(100);
        }
        return 0;
    }
    function changeTokenWallet(address _tokenWallet) external onlyOwner {
        require(_tokenWallet != address(0x0));
        tokenWallet = _tokenWallet;
        emit TokenWalletChanged(_tokenWallet);
    }
    function changeWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0x0));
        wallet = _wallet;
        emit WalletChanged(_wallet);
    }
}
