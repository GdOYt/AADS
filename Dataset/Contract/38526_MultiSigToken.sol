contract MultiSigToken is MultiSig {
    token public tokenFactory ;
    function MultiSigToken(address[] _owners, uint _required, token _addressOfTokenFactory)
        public
        MultiSig( _owners, _required)
    {    
        tokenFactory = token(_addressOfTokenFactory);
    }
    function()
    {
        throw;  
    }
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            if (tokenFactory.transfer(tx.destination, tx.value)) {
                tx.executed = true;
                Execution(transactionId);
            } else {
                tx.executed = false;
                ExecutionFailure(transactionId);
            }
        }
    }
}
