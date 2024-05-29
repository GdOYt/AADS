contract PortfolioFunctions is LoansFunctions{
    modifier isOwnerPortfolio(uint256 _indexPortfolio)  {
        require(banks[msg.sender].Portfolios[_indexPortfolio].Owner== msg.sender, "not the owner of portfolio");
        _;
    }
    function createPortfolio(uint256 _idLoan) isBank public  returns (uint256 )  {
            require(msg.sender== loans[_idLoan].Owner);
            Portfolio  memory  _portfolio;
            banks[msg.sender].Portfolios.push(_portfolio);
            banks[msg.sender].Portfolios[banks[msg.sender].Portfolios.length-1].idLoans.push(_idLoan);
            banks[msg.sender].Portfolios[banks[msg.sender].Portfolios.length-1].Owner= msg.sender;
            return banks[msg.sender].Portfolios.length-1;
    }
    function deletePortfolio(uint256 _indexPortfolio) isOwnerPortfolio(_indexPortfolio) public{
        uint256 _PortfolioLength = banks[msg.sender].Portfolios.length;
        banks[msg.sender].Portfolios[_indexPortfolio] = banks[msg.sender].Portfolios[_PortfolioLength -1];
        delete banks[msg.sender].Portfolios[_PortfolioLength -1];
        banks[msg.sender].Portfolios.length --;
    }
    function addLoanToPortfolio(uint256 _indexPortfolio, uint256 _idLoan) isOwnerPortfolio (_indexPortfolio) public {
        for(uint256 i; i<banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length;i++){
            if (banks[msg.sender].Portfolios[_indexPortfolio].idLoans[i]==_idLoan){
                require(false, "that loan already exists on the portfolio");
            }
        }
        banks[msg.sender].Portfolios[_indexPortfolio].idLoans.push(_idLoan);
    }
    function removeLoanFromPortfolio(uint256 _indexPortfolio, uint256 _idLoan) isOwnerPortfolio (_indexPortfolio) public returns (bool _result){
        uint256 Loanslength = banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length;
        uint256 _loanIndex = Loanslength;
        for(uint256 i; i<Loanslength; i++){
            if(_idLoan ==banks[msg.sender].Portfolios[_indexPortfolio].idLoans[i]){
                _loanIndex = i;
                i= Loanslength;
            }
        }
        require(_loanIndex<Loanslength, "el Loan no se encuentra en el Portfolio");
        if (_loanIndex !=banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length-1){
               banks[msg.sender].Portfolios[_indexPortfolio].idLoans[_loanIndex] = banks[msg.sender].Portfolios[_indexPortfolio].idLoans[Loanslength-1];
        }
        delete banks[msg.sender].Portfolios[_indexPortfolio].idLoans[Loanslength -1];
        banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length --;
        if (banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length == 0){
            deletePortfolio(_indexPortfolio);
        }
        _result = true;
    }    
    function getPortfolioInfo (address _bankAddress, uint256 _indexPortfolio) isBank  public view returns (uint256 _LoansLength, uint256 _forSale, address _owner){
        require(banks[_bankAddress].Portfolios[_indexPortfolio].Owner == _bankAddress, "not the owner of that portfolio");
        _LoansLength =    banks[_bankAddress].Portfolios[_indexPortfolio].idLoans.length;
        _forSale =    banks[_bankAddress].Portfolios[_indexPortfolio].forSale;
        _owner =    banks[_bankAddress].Portfolios[_indexPortfolio].Owner;
    }
    function sellPorftolio(uint256 _indexPortfolio, uint256 _value) isOwnerPortfolio (_indexPortfolio) public {
          require(banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length>0);
          banks[msg.sender].Portfolios[_indexPortfolio].forSale = _value;
    }
    function buyPortfolio(address _owner, uint256 _indexPortfolio, uint256 _value) isBank public {
        require(banks[msg.sender].Tokens>=_value);
        require(banks[_owner].Portfolios[_indexPortfolio].idLoans.length > 0);
        require(banks[_owner].Portfolios[_indexPortfolio].forSale > 0);
        require(banks[_owner].Portfolios[_indexPortfolio].forSale == _value );
        banks[msg.sender].Tokens = banks[msg.sender].Tokens.sub(_value);
        banks[_owner].Tokens = banks[_owner].Tokens.add(_value);
        for(uint256 a;a< banks[_owner].Portfolios[_indexPortfolio].idLoans.length ;a++){
           SwitchLoanOwner(_owner,  banks[_owner].Portfolios[_indexPortfolio].idLoans[a]);
        }
        if (_indexPortfolio !=banks[_owner].Portfolios.length-1){
               banks[_owner].Portfolios[_indexPortfolio] = banks[_owner].Portfolios[banks[_owner].Portfolios.length-1];         
        }
        delete banks[_owner].Portfolios[banks[_owner].Portfolios.length -1];
        banks[_owner].Portfolios.length--;
    }
    function countPortfolios(address _bankAddress) isBank public view returns (uint256 _result){
        _result = banks[_bankAddress].Portfolios.length;
    }
    function GetLoanIdFromPortfolio(uint256 _indexPortfolio, uint256 _indexLoan)  isBank public view returns(uint256 _ID){
        return banks[msg.sender].Portfolios[_indexPortfolio].idLoans[_indexLoan];
    }
}
