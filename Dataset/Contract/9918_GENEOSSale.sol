contract GENEOSSale is DSAuth, DSExec, DSMath {
    DSToken  public  GENEOS;                
    uint128  public  totalSupply = 1000000000000000000000000000;          
    uint128  public  foundersAllocation = 100000000000000000000000000;    
    string   public  foundersKey = "Dev key";           
    uint     public  createLastDay = 200000000000000000000000000;        
    uint     public  createPerDay = 4000000000000000000000000;          
    uint     public  numberOfDays = 175;         
    uint     public  startTime;                  
    uint     public  finalWindowTime;            
    uint     public  finishTime;
    address  public  foundersAddress = 0x37048f9C92a41fcE4535FDE3022B887b34D7eC0E;
    mapping (uint => uint)                       public  dailyTotals;
    mapping (uint => mapping (address => uint))  public  userBuys;
    mapping (uint => mapping (address => bool))  public  claimed;
    mapping (address => string)                  public  keys;
    event LogBuy      (uint window, address user, uint amount);
    event LogClaim    (uint window, address user, uint amount);
    event LogRegister (address user, string key);
    event LogCollect  (uint amount);
    event LogFreeze   ();
    function GENEOSSale(
        uint     _startTime
    ) {
        startTime = _startTime;
        finalWindowTime = startTime + (numberOfDays * 20 minutes);
        finishTime = finalWindowTime + 5 hours;
    }
    function initialize(DSToken geneos) auth {
        assert(address(GENEOS) == address(0));
        assert(geneos.owner() == address(this));
        assert(geneos.authority() == DSAuthority(0));
        assert(geneos.totalSupply() == 0);
        GENEOS = geneos;
        GENEOS.mint(totalSupply);
        GENEOS.push(foundersAddress, foundersAllocation);
        keys[foundersAddress] = foundersKey;
        LogRegister(foundersAddress, foundersKey);
    }
    function time() constant returns (uint) {
        return block.timestamp;
    }
    function today() constant returns (uint) {
        return dayFor(time());
    }
    function dayFor(uint timestamp) constant returns (uint) {
        if (timestamp < startTime) {
            return 0;
        }
        if (timestamp >= startTime && timestamp < finalWindowTime) {
            return sub(timestamp, startTime) / 5 minutes + 1;
        }
        if (timestamp >= finalWindowTime && timestamp < finishTime) {
            return 176;
        }
        return 999;
    }
    function createOnDay(uint day) constant returns (uint) {
        assert(day >= 1 && day <= 176);
        return day == 176 ? createLastDay : createPerDay;
    }
    function buyWithLimit(uint day, uint limit) payable {
        assert(today() > 0 && today() <= numberOfDays + 1);
        assert(msg.value >= 0.01 ether);
        assert(day >= today());
        assert(day <= numberOfDays + 1);
        userBuys[day][msg.sender] += msg.value;
        dailyTotals[day] += msg.value;
        if (limit != 0) {
            assert(dailyTotals[day] <= limit);
        }
        LogBuy(day, msg.sender, msg.value);
    }
    function buy() payable {
       buyWithLimit(today(), 0);
    }
    function () payable {
       buy();
    }
    function claim(uint day) {
        assert(today() > day);
        if (claimed[day][msg.sender] || dailyTotals[day] == 0) {
            return;
        }
        var dailyTotal = cast(dailyTotals[day]);
        var userTotal  = cast(userBuys[day][msg.sender]);
        var price      = wdiv(cast(createOnDay(day)), dailyTotal);
        var reward     = wmul(price, userTotal);
        claimed[day][msg.sender] = true;
        GENEOS.push(msg.sender, reward);
        LogClaim(day, msg.sender, reward);
    }
    function claimAll() {
        for (uint i = 0; i < today(); i++) {
            claim(i);
        }
    }
    function register(string key) {
        assert(today() <=  numberOfDays + 1);
        assert(bytes(key).length <= 64);
        keys[msg.sender] = key;
        LogRegister(msg.sender, key);
    }
    function collect() auth {
        assert(today() > 0);  
        exec(msg.sender, this.balance);
        LogCollect(this.balance);
    }
    function freeze() {
        assert(time() > finishTime);
        GENEOS.stop();
        LogFreeze();
    }
}
