contract ZethrShell is ZethrBankrollBridge{
    function WithdrawToBankroll() public {
        address(UsedBankrollAddresses[0]).transfer(address(this).balance);
    }
    function WithdrawAndTransferToBankroll() public {
        Zethr.withdraw();
        WithdrawToBankroll();
    }
}
