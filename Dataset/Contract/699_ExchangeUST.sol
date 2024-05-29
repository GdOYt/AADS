contract ExchangeUST is SafeMath, Owned, PUST {
    uint public ExerciseEndTime = 1546272000;
    uint public exchangeRate = 100000;  
    address public ustAddress = address(0xFa55951f84Bfbe2E6F95aA74B58cc7047f9F0644);
    address public officialAddress = address(0x472fc5B96afDbD1ebC5Ae22Ea10bafe45225Bdc6);
    event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);
    event exchange(address contractAddr, address reciverAddr, uint _pustBalance);
    event changeFeeAt(uint _exchangeRate);
    function chgExchangeRate(uint _exchangeRate) public onlyOwner {
        require (_exchangeRate != exchangeRate);
        require (_exchangeRate != 0);
        exchangeRate = _exchangeRate;
    }
    function exerciseOption(uint _pustBalance) public returns (bool) {
        require (now < ExerciseEndTime);
        require (_pustBalance <= balances[msg.sender]);
        uint _ether = safeMul(_pustBalance, 10 ** 18);
        require (address(this).balance >= _ether); 
        uint _amount = safeMul(_pustBalance, exchangeRate * 10**18);
        require (PUST(ustAddress).transferFrom(msg.sender, officialAddress, _amount) == true);
        balances[msg.sender] = safeSub(balances[msg.sender], _pustBalance);
        balances[officialAddress] = safeAdd(balances[officialAddress], _pustBalance);
        msg.sender.transfer(_ether);    
        emit exchange(address(this), msg.sender, _pustBalance);
    }
}
