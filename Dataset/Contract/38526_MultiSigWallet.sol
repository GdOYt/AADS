contract MultiSigWallet is MultiSig {
    function MultiSigWallet(address[] _owners, uint _required)
        public
        MultiSig( _owners, _required)
    {    
    }
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            if (tx.destination.call.value(tx.value)(tx.data)) {
                tx.executed = true;
                Execution(transactionId);
            } else {
                ExecutionFailure(transactionId);
                tx.executed = false;
            }
        }
    }
}
