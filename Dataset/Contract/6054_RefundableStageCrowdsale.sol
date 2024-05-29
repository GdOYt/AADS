contract RefundableStageCrowdsale is RefundableCrowdsale {
    function _forwardFunds() internal {
        vault.deposit.value(msg.value)(tx.origin);
    }
}
