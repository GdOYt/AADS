contract BankFunctions is ClientFunctions{
    modifier isBank(){
        require(banks[msg.sender].Owner==msg.sender, "you are not a bank");
        _;
    }
    modifier isLoanOwner(uint256 _id) {
        require(banks[msg.sender].Owner==msg.sender, "you are not a bank");
        require(loans[_id].Owner == msg.sender, "not owner of loan");
        _;
    }
    function GetClientCategory(address _client) isBank public view returns(uint256){
        return clients[_client].Category;
    } 
    function removeBankToken(uint256 _value) isBank public{
        require(banks[msg.sender].Tokens >= _value, "You don't have that many tokens");
        banks[msg.sender].Tokens = banks[msg.sender].Tokens.sub(_value);
    }
    function payOffClientDebt(uint256 _loanId, uint256 _value)  isLoanOwner(_loanId) public{
        require(loans[_loanId].Debt > 0);
        require(_value > 0);
        require(loans[_loanId].Debt>= _value);
        loans[loans.length-1].EndTime = now;
        loans[_loanId].Debt = loans[_loanId].Debt.sub(_value);
    }
    function ChangeInterest(uint256 _category, uint256 _amount, uint256 _installment, uint256 _value, bool _enable) isBank public{
        banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].value = _value;
        banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].enable = _enable;
    }
    function GetBankBalance() isBank public view returns (uint256 ){
        return banks[msg.sender].Tokens;
    }
    function findOutInterestByBank(uint256 _category, uint256 _amount, uint256 _installment) isBank public view returns(uint256 _value, bool _enable){
        _value = banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].value;
        _enable = banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].enable;
    }
}
