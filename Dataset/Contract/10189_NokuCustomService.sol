contract NokuCustomService is Pausable {
    using AddressUtils for address;
    event LogPricingPlanChanged(address indexed caller, address indexed pricingPlan);
    NokuPricingPlan public pricingPlan;
    constructor(address _pricingPlan) internal {
        require(_pricingPlan.isContract(), "_pricingPlan is not contract");
        pricingPlan = NokuPricingPlan(_pricingPlan);
    }
    function setPricingPlan(address _pricingPlan) public onlyOwner {
        require(_pricingPlan.isContract(), "_pricingPlan is not contract");
        require(NokuPricingPlan(_pricingPlan) != pricingPlan, "_pricingPlan equal to current");
        pricingPlan = NokuPricingPlan(_pricingPlan);
        emit LogPricingPlanChanged(msg.sender, _pricingPlan);
    }
}
