contract KissBTC is usingOraclize, Token {
    string constant PRICE_FEED =
        "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0";
    uint constant MAX_AMOUNT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint constant MAX_ETH_VALUE = 10 ether;
    uint constant MIN_ETH_VALUE = 50 finney;
    uint constant MAX_KISS_BTC_VALUE = 25000000;
    uint constant MIN_KISS_BTC_VALUE = 125000;
    uint constant DEFAULT_GAS_LIMIT = 200000;
    string public standard = "Token 0.1";
    string public name = "kissBTC";
    string public symbol = "kissBTC";
    uint8 public decimals = 8;
    struct Task {
        bytes32 oraclizeId;
        bool toKissBTC;
        address sender;
        uint value;
        address callback;
        uint timestamp;
    }
    mapping (uint => Task) public tasks;
    mapping (bytes32 => uint) public oraclizeRequests;
    uint public exchangeRate;
    uint public nextId = 1;
    address public owner;
    uint public timestamp;
    modifier onlyowner { if (msg.sender == owner) _ }
    function KissBTC() {
        owner = msg.sender;
    }
    function () {
        buyKissBTCWithCallback(0, DEFAULT_GAS_LIMIT);
    }
    function buyKissBTC() {
        buyKissBTCWithCallback(0, DEFAULT_GAS_LIMIT);
    }
    function buyKissBTCWithCallback(address callback,
                                    uint gasLimit) oraclizeAPI
                                    returns (uint id) {
        if (msg.value < MIN_ETH_VALUE || msg.value > MAX_ETH_VALUE) throw;
        if (gasLimit < DEFAULT_GAS_LIMIT) gasLimit = DEFAULT_GAS_LIMIT;
        uint oraclizePrice = oraclize.getPrice("URL", gasLimit);
        uint fee = msg.value / 100;  
        if (msg.value <= oraclizePrice + fee) throw;
        uint value = msg.value - (oraclizePrice + fee);
        id = nextId++;
        bytes32 oraclizeId = oraclize.query_withGasLimit.value(oraclizePrice)(
            0,
            "URL",
            PRICE_FEED,
            gasLimit
        );
        tasks[id].oraclizeId = oraclizeId;
        tasks[id].toKissBTC = true;
        tasks[id].sender = msg.sender;
        tasks[id].value = value;
        tasks[id].callback = callback;
        tasks[id].timestamp = now;
        oraclizeRequests[oraclizeId] = id;
    }
    function transfer(address _to,
                      uint256 _amount) noEther returns (bool success) {
        if (_to == address(this)) {
            sellKissBTCWithCallback(_amount, 0, DEFAULT_GAS_LIMIT);
            return true;
        } else {
            return _transfer(_to, _amount);     
        }
    }
    function transferFrom(address _from,
                          address _to,
                          uint256 _amount) noEther returns (bool success) {
        if (_to == address(this)) throw;        
        return _transferFrom(_from, _to, _amount);
    }
    function sellKissBTC(uint256 _amount) returns (uint id) {
        return sellKissBTCWithCallback(_amount, 0, DEFAULT_GAS_LIMIT);
    }
    function sellKissBTCWithCallback(uint256 _amount,
                                     address callback,
                                     uint gasLimit) oraclizeAPI
                                     returns (uint id) {
        if (_amount < MIN_KISS_BTC_VALUE
            || _amount > MAX_KISS_BTC_VALUE) throw;
        if (balances[msg.sender] < _amount) throw;
        if (gasLimit < DEFAULT_GAS_LIMIT) gasLimit = DEFAULT_GAS_LIMIT;
        if (!safeToSell(_amount)) throw;     
        uint oraclizePrice = oraclize.getPrice("URL", gasLimit);
        uint oraclizePriceKissBTC = inKissBTC(oraclizePrice);
        uint fee = _amount / 100;  
        if (_amount <= oraclizePriceKissBTC + fee) throw;
        uint value = _amount - (oraclizePriceKissBTC + fee);
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        Transfer(msg.sender, address(this), _amount);
        id = nextId++;
        bytes32 oraclizeId = oraclize.query_withGasLimit.value(oraclizePrice)(
            0,
            "URL",
            PRICE_FEED,
            gasLimit
        );
        tasks[id].oraclizeId = oraclizeId;
        tasks[id].toKissBTC = false;
        tasks[id].sender = msg.sender;
        tasks[id].value = value;
        tasks[id].callback = callback;
        tasks[id].timestamp = now;
        oraclizeRequests[oraclizeId] = id;
    }
    function inKissBTC(uint amount) constant returns (uint) {
        return (amount * exchangeRate) / 1000000000000000000;
    }
    function inEther(uint amount) constant returns (uint) {
        return (amount * 1000000000000000000) / exchangeRate;
    }
    function safeToSell(uint amount) constant returns (bool) {
        return inEther(amount) * 125 < this.balance * 100;
    }
    function __callback(bytes32 oraclizeId, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        uint _exchangeRate = parseInt(result, 6) * 100;
        if (_exchangeRate > 0) {
            exchangeRate = _exchangeRate;
        }
        uint id = oraclizeRequests[oraclizeId];
        if (id == 0) return;
        address sender = tasks[id].sender;
        address callback = tasks[id].callback;
        if (tasks[id].toKissBTC) {
            uint freshKissBTC = inKissBTC(tasks[id].value);
            totalSupply += freshKissBTC;
            balances[sender] += freshKissBTC;
            Transfer(address(this), sender, freshKissBTC);
            if (callback != 0) {
                KissBTCCallback(callback).kissBTCCallback.
                    value(0)(id, freshKissBTC);
            }
        } else {
            uint releasedEther = inEther(tasks[id].value);
            sender.send(releasedEther);
            if (callback != 0) {
                KissBTCCallback(callback).kissBTCCallback.
                    value(0)(id, releasedEther);
            }
        }
        delete oraclizeRequests[oraclizeId];
        delete tasks[id];
    }
    function retryOraclizeRequest(uint id) oraclizeAPI {
        if (tasks[id].oraclizeId == 0) throw;
        uint timePassed = now - tasks[id].timestamp;
        if (timePassed < 60 minutes) throw;
        uint price = oraclize.getPrice("URL", DEFAULT_GAS_LIMIT);
        bytes32 newOraclizeId = oraclize.query_withGasLimit.value(price)(
            0,
            "URL",
            PRICE_FEED,
            DEFAULT_GAS_LIMIT
        );
        delete oraclizeRequests[tasks[id].oraclizeId];
        tasks[id].oraclizeId = newOraclizeId;
        tasks[id].callback = 0;
        tasks[id].timestamp = now;
        oraclizeRequests[newOraclizeId] = id;
    }
    function whitelist(address _spender) returns (bool success) {
        return approve(_spender, MAX_AMOUNT);
    }
    function approveAndCall(address _spender,
                            uint256 _amount,
                            bytes _extraData) returns (bool success) {
        approve(_spender, _amount);
        ApprovalRecipient(_spender).receiveApproval.
            value(0)(msg.sender, _amount, this, _extraData);
        return true;
    }
    function donate() {
    }
    function toldYouItWouldWork() onlyowner {
        if (now - timestamp < 24 hours) throw;   
        uint obligations = inEther(totalSupply);
        if (this.balance <= obligations * 3) throw;
        uint excess = this.balance - (obligations * 3);
        uint payment = excess / 100;
        if (payment > 0) owner.send(payment);
        timestamp = now;
    }
    function setOwner(address _owner) onlyowner {
        owner = _owner;
    }
}
