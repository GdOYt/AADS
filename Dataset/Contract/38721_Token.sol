contract Token is Owned, Mutex {
    uint ONE = 10**8;
    uint price = 5000;
    Ledger ledger;
    Rental rentalContract;
    uint8 rollOverTime = 4;
    uint8 startTime = 8;
    bool live = false;
    address club;
    uint lockedSupply = 0;
    string public name;
    uint8 public decimals; 
    string public symbol;     
    string public version = '0.1';  
    bool transfersOn = false;
    function Token(address _owner, string _tokenName, uint8 _decimals, string _symbol, address _ledger, address _rental) {
        if (_owner == 0x0) throw;
        owner = _owner;
        name = _tokenName;
        decimals = _decimals;
        symbol = _symbol;
        ONE = 10**uint(decimals);
        ledger = Ledger(_ledger);
        rentalContract = Rental(_rental);
    }
    event LedgerUpdated(address,address);
    function changeClub(address _addr) onlyOwner {
        if (_addr == 0x0) throw;
        club = _addr;
    }
    function changePrice(uint _num) onlyOwner {
        price = _num;
    }
    function safeAdd(uint a, uint b) returns (uint) {
        if ((a + b) < a) throw;
        return (a + b);
    }
    function changeLedger(address _addr) onlyOwner {
        if (_addr == 0x0) throw;
        LedgerUpdated(msg.sender, _addr);
        ledger = Ledger(_addr);
    }
    function changeRental(address _addr) onlyOwner {
        if (_addr == 0x0) throw;
        rentalContract = Rental(_addr);
    }
    function changeTimes(uint8 _rollOver, uint8 _start) onlyOwner {
        rollOverTime = _rollOver;
        startTime = _start;
    }
    function lock(address _seizeAddr) onlyOwner mutexed {
        uint myBalance = ledger.balanceOf(_seizeAddr);
        lockedSupply += myBalance;
        ledger.setBalance(_seizeAddr, 0);
    }
    event Dilution(address, uint);
    function dilute(address _destAddr, uint amount) onlyOwner {
        if (amount > lockedSupply) throw;
        Dilution(_destAddr, amount);
        lockedSupply -= amount;
        uint curBalance = ledger.balanceOf(_destAddr);
        curBalance = safeAdd(amount, curBalance);
        ledger.setBalance(_destAddr, curBalance);
    }
    function completeCrowdsale() onlyOwner {
        transfersOn = true;
        lock(owner);
    }
    function pauseTransfers() onlyOwner {
        transfersOn = false;
    }
    function resumeTransfers() onlyOwner {
        transfersOn = true;
    }
    function rentOut(uint num) {
        if (ledger.balanceOf(msg.sender) < num) throw;
        rentalContract.offer(msg.sender, num);
        ledger.tokenTransfer(msg.sender, rentalContract, num);
    }
    function claimUnrented() {  
        uint amount = rentalContract.claimBalance(msg.sender);  
        ledger.tokenTransfer(rentalContract, msg.sender, amount);
    }
    function burn(uint _amount) {
        uint balance = ledger.balanceOf(msg.sender);
        if (_amount > balance) throw;
        ledger.setBalance(msg.sender, balance - _amount);
    }
    function checkIn(uint _numCheckins) returns(bool) {
        int needed = int(price * ONE* _numCheckins);
        if (int(ledger.balanceOf(msg.sender)) > needed) {
            ledger.changeUsed(msg.sender, needed);
            return true;
        }
        return false;
    }
    event Transfer(address, address, uint);
    event Approval(address, address, uint);
    function totalSupply() constant returns(uint) {
        return ledger.totalSupply();
    }
    function transfer(address _to, uint _amount) returns(bool) {
        if (!transfersOn && msg.sender != owner) return false;
        if (! ledger.tokenTransfer(msg.sender, _to, _amount)) { return false; }
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint _amount) returns (bool) {
        if (!transfersOn && msg.sender != owner) return false;
        if (! ledger.tokenTransferFrom(msg.sender, _from, _to, _amount) ) { return false;}
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    function allowance(address _from, address _to) constant returns(uint) {
        return ledger.allowance(_from, _to); 
    }
    function approve(address _spender, uint _value) returns (bool) {
        if ( ledger.tokenApprove(msg.sender, _spender, _value) ) {
            Approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }
    function balanceOf(address _addr) constant returns(uint) {
        return ledger.balanceOf(_addr);
    }
}
