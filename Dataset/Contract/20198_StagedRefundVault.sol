contract StagedRefundVault is RefundVault {
    event ClosedStage();
    event Active();
    function StagedRefundVault (address _wallet) public
        RefundVault(_wallet) {
    }
    function stageClose() onlyOwner public {
        ClosedStage();
        wallet.transfer(this.balance);
    }
    function activate() onlyOwner public {
        require(state == State.Refunding);
        state = State.Active;
        Active();
    }
}
