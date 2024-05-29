contract LimitedMinPurchaseCrowdsale is Crowdsale {
    using SafeMath for uint256;
    uint256 public minPurchase;
    constructor(uint256 _minPurchase) public {
        require(
            _minPurchase > 0,
            "Call with insufficient _minPurchase."
        );
        minPurchase = _minPurchase;
    }
    modifier overMinPurchaseLimit(uint256 _weiAmount) {
        require(
            _weiAmount >= minPurchase,
            "Call with insufficient _weiAmount."
        );
        _;
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal overMinPurchaseLimit(_weiAmount) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
