contract FinalizableFundraiser is BasicFundraiser {
    bool public isFinalized = false;
    event Finalized();
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());
        finalization();
        emit Finalized();
        isFinalized = true;
    }
    function finalization() internal {
        beneficiary.transfer(address(this).balance);
    }
    function handleFunds(address, uint256) internal {
    }
}
