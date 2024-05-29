contract ClientFunctions is Base{
    modifier isClient(){
        require(clients[msg.sender].Owner == msg.sender, "not a client");
        _;
    }
    function askForALoan(address _bankAddress, uint256 _amount, uint256 _installment) isClient public  {
        require(banks[_bankAddress].Owner==_bankAddress, "not a valid bank");
        require(banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].enable, "you not apply for that loan");
        Loan memory _loan;
        _loan.Debt = _amount;
        _loan.Debt  = _loan.Debt.add(banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].value);
        _loan.Client = msg.sender;
        _loan.Owner = _bankAddress;
        _loan.Installment = _installment;
        _loan.Category = clients[msg.sender].Category;
        _loan.Amount = _amount;
        banks[_bankAddress].LoanPending.push(_loan);
    }
    function findOutInterestByClientCategory(address _bankAddress, uint256 _amount, uint256 _installment) isClient public view returns(uint256 _value, bool _enable){
        _value = banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].value;
        _enable = banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].enable;
    }
    function removeClientToken(uint256 _value) isClient public{
        require(clients[msg.sender].Tokens >= _value, "You don't have that many tokens");
        clients[msg.sender].Tokens = clients[msg.sender].Tokens.sub(_value);
    }
    function getClientBalance() isClient public view returns (uint256 _value){
        _value = clients[msg.sender].Tokens;
    }
    function getLoansLengthByClient() isClient public view returns(uint256){
        return clients[msg.sender].LoansID.length;
    }
    function getLoanIDbyClient(uint256 _indexLoan) isClient public view returns (uint256){
        return clients[msg.sender].LoansID[_indexLoan];
    }
    function getClientCategory() isClient public view returns(uint256){
        return clients[msg.sender].Category;
    } 
}
