contract NokuPricingPlan {
    function payFee(bytes32 serviceName, uint256 multiplier, address client) public returns(bool paid);
    function usageFee(bytes32 serviceName, uint256 multiplier) public view returns(uint fee);
}
