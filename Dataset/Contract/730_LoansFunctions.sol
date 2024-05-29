contract LoansFunctions is BankFunctions{
    function SellLoan(uint256 _loanId, uint256 _value) isLoanOwner(_loanId)  public {
        loans[_loanId].ForSale = _value;
    }
    function BuyLoan(address _owner, uint256 _loanId, uint256 _value)  isBank public{
        require(loans[_loanId].ForSale > 0, "not for sale");
        require(banks[msg.sender].Tokens>= _value, "you don't have money");
        SwitchLoanOwner( _owner,  _loanId);        
        banks[msg.sender].Tokens = banks[msg.sender].Tokens.sub(_value);
        banks[_owner].Tokens = banks[_owner].Tokens.add(_value);
    }
    function SwitchLoanOwner(address _owner, uint256 _loanId) internal{
        require(loans[_loanId].Debt> 0, "at least one of the loans is already paid");
        require(loans[_loanId].Owner == _owner);
        uint256 _indexLoan;
        for (uint256 i; i<banks[_owner].LoansID.length; i++){
            if (banks[_owner].LoansID[i] == _loanId){
                _indexLoan = i;
                i =  banks[_owner].LoansID.length.add(1);
            }
        }
        banks[msg.sender].LoansID.push(_loanId);
        if (_indexLoan !=banks[_owner].LoansID.length - 1){
                banks[_owner].LoansID[_indexLoan] = banks[_owner].LoansID[banks[_owner].LoansID.length - 1];         
        }
        delete banks[_owner].LoansID[banks[_owner].LoansID.length -1];
        banks[_owner].LoansID.length --;
        loans[_loanId].ForSale = 0;
        loans[_loanId].Owner = msg.sender;
    }
    function aproveLoan(uint256 _loanIndex) public {
        require(banks[msg.sender].LoanPending[_loanIndex].Owner == msg.sender, "you are not the owner");
        require(banks[msg.sender].Tokens>=banks[msg.sender].LoanPending[_loanIndex].Amount, "the bank does not have that amount of tokens");
        banks[msg.sender].LoanPending[_loanIndex].Id =loans.length;
        loans.push(banks[msg.sender].LoanPending[_loanIndex]);
        loans[loans.length-1].StartTime = now;
        address _client = banks[msg.sender].LoanPending[_loanIndex].Client;
        uint256 _amount  = banks[msg.sender].LoanPending[_loanIndex].Amount;
        banks[msg.sender].LoansID.push(loans.length - 1);
        clients[_client].LoansID.push(loans.length - 1);
        clients[_client].Tokens =  clients[_client].Tokens.add(_amount);
        banks[msg.sender].Tokens =  banks[msg.sender].Tokens.sub(_amount);
        if(banks[msg.sender].LoanPending.length !=1){
            banks[msg.sender].LoanPending[_loanIndex] = banks[msg.sender].LoanPending [banks[msg.sender].LoanPending.length - 1];    
        }
        delete banks[msg.sender].LoanPending [banks[msg.sender].LoanPending.length - 1];
        banks[msg.sender].LoanPending.length--;
    }
    function GetLoansLenght(bool _pending) public isBank view returns (uint256) {
        if (_pending){
            return banks[msg.sender].LoanPending.length;    
        }else{
            return banks[msg.sender].LoansID.length;
        }
    }
    function GetLoanInfo(uint256 _indexLoan, bool _pending)  public view returns(uint256 _debt, address _client, uint256 _installment, uint256 _category , uint256 _amount, address _owner, uint256 _forSale, uint256 _StartTime, uint256 _EndTime){
        Loan memory _loan;
        if (_pending){
            require (_indexLoan < banks[msg.sender].LoanPending.length, "null value");
            _loan = banks[msg.sender].LoanPending[_indexLoan];
        }else{
            _loan = loans[_indexLoan];
        }
        _debt = _loan.Debt;
        _client =  _loan.Client;
        _installment =  _loan.Installment;
        _category = _loan.Category;
        _amount = _loan.Amount ;
        _owner = _loan.Owner ;
        _forSale = _loan.ForSale;
        _StartTime = _loan.StartTime;
        _EndTime = _loan.EndTime;
    }
}
