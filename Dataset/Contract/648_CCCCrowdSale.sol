contract CCCCrowdSale is Crowdsale {
    constructor(uint256 _rate, address _wallet, address _tokenAddress) Crowdsale(_rate,_wallet, ERC20(_tokenAddress)) public {
    }
}
