contract ICOCappedRefundableCrowdsale is CappedCrowdsale, ICOCrowdsale, RefundableCrowdsale {
    constructor(uint256 startTime, uint256 endTime, uint256 hardCap, uint256 softCap, address wallet, address HookOperatorContractAddress) public
        FinalizableCrowdsale()
        ICOCrowdsale(startTime, endTime, wallet, HookOperatorContractAddress)
        CappedCrowdsale(hardCap)
        RefundableCrowdsale(softCap)
    {
        require(softCap <= hardCap);
    }
}
