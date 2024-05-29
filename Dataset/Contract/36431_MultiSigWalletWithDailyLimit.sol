contract MultiSigWalletWithDailyLimit is MultiSigWallet {
    event DailyLimitChange(uint dailyLimit);
    uint public dailyLimit;
    uint public lastDay;
    uint public spentToday;
    function MultiSigWalletWithDailyLimit()
    public
    MultiSigWallet()
    {
    }
    function setInitAttr(address[] _owners, uint _required, uint _dailyLimit)
    public
    validRequirement(_owners.length, _required)
    onlyOnceSetOwners
    onlyCreator
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
            throw;
            isOwner[_owners[i]] = true;
        }
        dailyLimit = _dailyLimit;
        owners = _owners;
        required = _required;
        onceSetOwners = onceSetOwners - 1;
    }
    function changeDailyLimit(uint _dailyLimit)
    public
    onlyWallet
    {
        dailyLimit = _dailyLimit;
        DailyLimitChange(_dailyLimit);
    }
    function executeTransaction(uint transactionId)
    public
    notExecuted(transactionId)
    {
        Transaction tx = transactions[transactionId];
        bool confirmed = isConfirmed(transactionId);
        if (confirmed || tx.data.length == 0 && isUnderLimit(tx.value)) {
            tx.executed = true;
            if (!confirmed)
            spentToday += tx.value;
            if (tx.destination.call.value(tx.value)(tx.data))
            Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                tx.executed = false;
                if (!confirmed)
                spentToday -= tx.value;
            }
        }
    }
    function isUnderLimit(uint amount)
    internal
    returns (bool)
    {
        if (now > lastDay + 24 hours) {
            lastDay = now;
            spentToday = 0;
        }
        if (spentToday + amount > dailyLimit || spentToday + amount < spentToday)
        return false;
        return true;
    }
    function calcMaxWithdraw()
    public
    constant
    returns (uint)
    {
        if (now > lastDay + 24 hours)
        return dailyLimit;
        if (dailyLimit < spentToday)
        return 0;
        return dailyLimit - spentToday;
    }
}
