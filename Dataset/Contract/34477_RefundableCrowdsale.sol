contract RefundableCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;
    uint public goal;
    RefundVault public vault;
    function RefundableCrowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token, uint _goal)
            FinalizableCrowdsale(_startTime, _endTime, _rate, _hardCap, _wallet, _token) {
        require(_goal > 0);
        vault = new RefundVault(wallet);
        goal = _goal;
    }
    function forwardFunds(uint amountWei) internal {
        if (goalReached()) {
            wallet.transfer(amountWei);
        }
        else {
            vault.deposit.value(amountWei)(msg.sender);
        }
    }
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());
        vault.refund(msg.sender, weiRaised);
    }
    function finalization() internal {
        super.finalization();
        if (goalReached()) {
            vault.close();
        }
        else {
            vault.enableRefunds();
        }
    }
    function goalReached() public constant returns (bool) {
        return weiRaised >= goal;
    }
}
