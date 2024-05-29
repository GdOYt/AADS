contract DepositManager is Ownable {
    address public actualSalesAddress;
    function DepositManager (address _actualAddres) public {
        actualSalesAddress = _actualAddres;
    }
    function () payable public {
        SalesManagerUpgradable sm = SalesManagerUpgradable(actualSalesAddress);
        if(!sm.buyTokens.value(msg.value)(msg.sender)) revert();
    }
    function setNewSalesManager (address _newAddr) public onlyOwner {
        actualSalesAddress = _newAddr;
    }
}
