contract kkkTokenSale is DSStop, DSMath, DSExec {
    DSToken public kkk;
    uint128 public constant PUBLIC_SALE_PRICE = 200000 ether;
    uint128 public constant TOTAL_SUPPLY = 10 ** 11 * 1 ether;   
    uint128 public constant SELL_SOFT_LIMIT = TOTAL_SUPPLY * 12 / 100;  
    uint128 public constant SELL_HARD_LIMIT = TOTAL_SUPPLY * 16 / 100;  
    uint128 public constant FUTURE_DISTRIBUTE_LIMIT = TOTAL_SUPPLY * 84 / 100;  
    uint128 public constant USER_BUY_LIMIT = 500 ether;  
    uint128 public constant MAX_GAS_PRICE = 50000000000;   
    uint public startTime;
    uint public endTime;
    bool public moreThanSoftLimit;
    mapping (address => uint)  public  userBuys;  
    address public destFoundation;  
    uint128 public sold;
    uint128 public constant soldByChannels = 40000 * 200000 ether;  
    function kkkTokenSale(uint startTime_, address destFoundation_) {
        kkk = new DSToken("kkk");
        destFoundation = destFoundation_;
        startTime = startTime_;
        endTime = startTime + 14 days;
        sold = soldByChannels;  
        kkk.mint(TOTAL_SUPPLY);
        kkk.transfer(destFoundation, FUTURE_DISTRIBUTE_LIMIT);
        kkk.transfer(destFoundation, soldByChannels);
        kkk.stop();
    }
    function time() constant returns (uint) {
        return now;
    }
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
        size := extcodesize(_addr)
        }
        return size > 0;
    }
    function canBuy(uint total) returns (bool) {
        return total <= USER_BUY_LIMIT;
    }
    function() payable stoppable note {
        require(!isContract(msg.sender));
        require(msg.value >= 0.01 ether);
        require(tx.gasprice <= MAX_GAS_PRICE);
        assert(time() >= startTime && time() < endTime);
        var toFund = cast(msg.value);
        var requested = wmul(toFund, PUBLIC_SALE_PRICE);
        if( add(sold, requested) >= SELL_HARD_LIMIT) {
            requested = SELL_HARD_LIMIT - sold;
            toFund = wdiv(requested, PUBLIC_SALE_PRICE);
            endTime = time();
        }
        var totalUserBuy = add(userBuys[msg.sender], toFund);
        assert(canBuy(totalUserBuy));
        userBuys[msg.sender] = totalUserBuy;
        sold = hadd(sold, requested);
        if( !moreThanSoftLimit && sold >= SELL_SOFT_LIMIT ) {
            moreThanSoftLimit = true;
            endTime = time() + 24 hours;  
        }
        kkk.start();
        kkk.transfer(msg.sender, requested);
        kkk.stop();
        exec(destFoundation, toFund);  
        uint toReturn = sub(msg.value, toFund);
        if(toReturn > 0) {
            exec(msg.sender, toReturn);
        }
    }
    function setStartTime(uint startTime_) auth note {
        require(time() <= startTime && time() <= startTime_);
        startTime = startTime_;
        endTime = startTime + 14 days;
    }
    function finalize() auth note {
        require(time() >= endTime);
        kkk.start();
        kkk.transfer(destFoundation, kkk.balanceOf(this));
        kkk.setOwner(destFoundation);
    }
    function transferTokens(address dst, uint wad, address _token) public auth note {
        ERC20 token = ERC20(_token);
        token.transfer(dst, wad);
    }
    function summary()constant returns(
        uint128 _sold,
        uint _startTime,
        uint _endTime)
        {
        _sold = sold;
        _startTime = startTime;
        _endTime = endTime;
        return;
    }
}
