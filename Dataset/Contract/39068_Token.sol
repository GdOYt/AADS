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
    string public name = "Legends";
    uint8 public decimals = 8;
    string public symbol = "LGD";
    string public version = '1.1';
    bool transfersOn = false;
    modifier onlyInputWords(uint n) {
        if (msg.data.length != (32 * n) + 4) throw;
        _;
    }
    function Token() {
        owner = msg.sender;
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
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    function totalSupply() constant returns(uint) {
        return ledger.totalSupply();
    }
    function transfer(address _to, uint _amount) onlyInputWords(2) returns(bool) {
        if (!transfersOn && msg.sender != owner) return false;
        if (!ledger.tokenTransfer(msg.sender, _to, _amount)) { return false; }
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint _amount) onlyInputWords(3) returns (bool) {
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
