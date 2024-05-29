contract RefundableFundraiser is FinalizableFundraiser {
    uint256 public softCap;
    RefundSafe public refundSafe;
    function initializeRefundableFundraiser(uint256 _softCap) internal {
        require(_softCap > 0);
        refundSafe = new RefundSafe(address(this), beneficiary);
        softCap = _softCap;
    }
    function handleFunds(address _address, uint256 _ethers) internal {
        refundSafe.deposit.value(_ethers)(_address);
    }
    function softCapReached() public view returns (bool) {
        return totalRaised >= softCap;
    }
    function getRefund() public {
        require(isFinalized);
        require(!softCapReached());
        refundSafe.refund(msg.sender);
    }
    function setBeneficiary(address _beneficiary) public onlyOwner {
        super.setBeneficiary(_beneficiary);
        refundSafe.setBeneficiary(_beneficiary);
    }
    function finalization() internal {
        super.finalization();
        if (softCapReached()) {
            refundSafe.close();
        } else {
            refundSafe.allowRefunds();
        }
    }
}
