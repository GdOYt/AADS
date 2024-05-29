contract TokensRollStageCrowdsale is FinalizableCrowdsale {
    address public rollAddress;
    modifier havingRollAddress() {
        require(rollAddress != address(0), "Call when no roll address set.");
        _;
    }
    function finalization() internal havingRollAddress {
        super.finalization();
        token.transfer(rollAddress, token.balanceOf(this));
    }
    function setRollAddress(address _rollAddress) public onlyOwner {
        require(_rollAddress != address(0), "Call with invalid _rollAddress.");
        rollAddress = _rollAddress;
    }
}
