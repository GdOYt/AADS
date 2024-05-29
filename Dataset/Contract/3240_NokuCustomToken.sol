contract NokuCustomToken is Ownable {
    event LogBurnFinished();
    event LogPricingPlanChanged(address indexed caller, address indexed pricingPlan);
    NokuPricingPlan public pricingPlan;
    address public serviceProvider;
    bool public burningFinished;
    modifier onlyServiceProvider() {
        require(msg.sender == serviceProvider, "caller is not service provider");
        _;
    }
    modifier canBurn() {
        require(!burningFinished, "burning finished");
        _;
    }
    constructor(address _pricingPlan, address _serviceProvider) internal {
        require(_pricingPlan != 0, "_pricingPlan is zero");
        require(_serviceProvider != 0, "_serviceProvider is zero");
        pricingPlan = NokuPricingPlan(_pricingPlan);
        serviceProvider = _serviceProvider;
    }
    function isCustomToken() public pure returns(bool isCustom) {
        return true;
    }
    function finishBurning() public onlyOwner canBurn returns(bool finished) {
        burningFinished = true;
        emit LogBurnFinished();
        return true;
    }
    function setPricingPlan(address _pricingPlan) public onlyServiceProvider {
        require(_pricingPlan != 0, "_pricingPlan is 0");
        require(_pricingPlan != address(pricingPlan), "_pricingPlan == pricingPlan");
        pricingPlan = NokuPricingPlan(_pricingPlan);
        emit LogPricingPlanChanged(msg.sender, _pricingPlan);
    }
}
