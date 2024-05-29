contract Ledger is Owned {
    uint ONE = 10**8;
    uint preMined = 30000000;
    mapping (address => uint) balances;
    mapping (address => uint) usedToday;
    mapping (address => bool) seenHere;
    address[] public seenHereA;
    mapping (address => mapping (address => uint256)) allowed;
    address token;
    uint public totalSupply = 0;
    function Ledger() {
        owner = msg.sender;
        seenHere[owner] = true;
        seenHereA.push(owner);
        totalSupply = preMined *ONE;
        balances[owner] = totalSupply;
    }
    modifier onlyToken {
        if (msg.sender != token) throw;
        _;
    }
    modifier onlyTokenOrOwner {
        if (msg.sender != token && msg.sender != owner) throw;
        _;
    }
    function tokenTransfer(address _from, address _to, uint amount) onlyToken returns(bool) {
        if (amount > balances[_from]) return false;
        if ((balances[_to] + amount) < balances[_to]) return false;
        if (amount == 0) { return false; }
        balances[_from] -= amount;
        balances[_to] += amount;
        if (seenHere[_to] == false) {
            seenHereA.push(_to);
            seenHere[_to] = true;
        }
        return true;
    }
    function tokenTransferFrom(address _sender, address _from, address _to, uint amount) onlyToken returns(bool) {
        if (allowed[_from][_sender] <= amount) return false;
        if (amount > balanceOf(_from)) return false;
        if (amount == 0) return false;
        if ((balances[_to] + amount) < amount) return false;
        balances[_from] -= amount;
        balances[_to] += amount;
        allowed[_from][_sender] -= amount;
        if (seenHere[_to] == false) {
            seenHereA.push(_to);
            seenHere[_to] = true;
        }
        return true;
    }
    function changeUsed(address _addr, int amount) onlyToken {
        int myToday = int(usedToday[_addr]) + amount;
        usedToday[_addr] = uint(myToday);
    }
    function resetUsedToday(uint8 startI, uint8 numTimes) onlyTokenOrOwner returns(uint8) {
        uint8 numDeleted;
        for (uint i = 0; i < numTimes && i + startI < seenHereA.length; i++) {
            if (usedToday[seenHereA[i+startI]] != 0) {
                delete usedToday[seenHereA[i+startI]];
                numDeleted++;
            }
        }
        return numDeleted;
    }
    function balanceOf(address _addr) constant returns (uint) {
        if (usedToday[_addr] >= balances[_addr]) { return 0;}
        return balances[_addr] - usedToday[_addr];
    }
    event Approval(address, address, uint);
    function tokenApprove(address _from, address _spender, uint256 _value) onlyToken returns (bool) {
        allowed[_from][_spender] = _value;
        Approval(_from, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function changeToken(address _token) onlyOwner {
        token = Token(_token);
    }
    function reduceTotalSupply(uint amount) onlyToken {
        if (amount > totalSupply) throw;
        totalSupply -= amount;
    }
    function setBalance(address _addr, uint amount) onlyTokenOrOwner {
        if (balances[_addr] == amount) { return; }
        if (balances[_addr] < amount) {
            uint increase = amount - balances[_addr];
            totalSupply += increase;
        } else {
            uint decrease = balances[_addr] - amount;
            totalSupply -= decrease;
        }
        balances[_addr] = amount;
    }
}
