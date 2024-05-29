contract PullPaymentCapable {
    uint256 private totalBalance;
    mapping(address => uint256) private payments;
    event LogPaymentReceived(address indexed dest, uint256 amount);
    function PullPaymentCapable() {
        if (0 < this.balance) {
            asyncSend(msg.sender, this.balance);
        }
    }
    function asyncSend(address dest, uint256 amount) internal {
        if (amount > 0) {
            totalBalance += amount;
            payments[dest] += amount;
            LogPaymentReceived(dest, amount);
        }
    }
    function getTotalBalance()
        constant
        returns (uint256) {
        return totalBalance;
    }
    function getPaymentOf(address beneficiary) 
        constant
        returns (uint256) {
        return payments[beneficiary];
    }
    function withdrawPayments()
        external 
        returns (bool success) {
        uint256 payment = payments[msg.sender];
        payments[msg.sender] = 0;
        totalBalance -= payment;
        if (!msg.sender.call.value(payment)()) {
            throw;
        }
        success = true;
    }
    function fixBalance()
        returns (bool success);
    function fixBalanceInternal(address dest)
        internal
        returns (bool success) {
        if (totalBalance < this.balance) {
            uint256 amount = this.balance - totalBalance;
            payments[dest] += amount;
            LogPaymentReceived(dest, amount);
        }
        return true;
    }
}
