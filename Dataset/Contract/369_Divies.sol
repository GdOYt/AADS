contract Divies {
    using SafeMath for uint256;
    using UintCompressor for uint256;
    HourglassInterface constant H4Dcontract_ = HourglassInterface(0xeB0b5FA53843aAa2e636ccB599bA4a8CE8029aA1);
    uint256 public pusherTracker_ = 100;
    mapping (address => Pusher) public pushers_;
    struct Pusher
    {
        uint256 tracker;
        uint256 time;
    }
    uint256 public rateLimiter_;
    modifier isHuman() {
        require(tx.origin == msg.sender);
        _;
    }
    function balances()
        public
        view
        returns(uint256)
    {
        return (address(this).balance);
    }
    function deposit()
        external
        payable
    {
    }
    function() external payable {}
    event onDistribute(
        address pusher,
        uint256 startingBalance,
        uint256 masternodePayout,
        uint256 finalBalance,
        uint256 compressedData
    );
    function distribute(uint256 _percent)
        public
        isHuman()
    {
        require(_percent > 0 && _percent < 100, "please pick a percent between 1 and 99");
        address _pusher = msg.sender;
        uint256 _bal = address(this).balance;
        uint256 _mnPayout;
        uint256 _compressedData;
        if (
            pushers_[_pusher].tracker <= pusherTracker_.sub(100) &&  
            pushers_[_pusher].time.add(1 hours) < now                
        )
        {
            pushers_[_pusher].tracker = pusherTracker_;
            pusherTracker_++;
            if (H4Dcontract_.balanceOf(_pusher) >= H4Dcontract_.stakingRequirement())
                _mnPayout = (_bal / 10) / 3;
            uint256 _stop = (_bal.mul(100 - _percent)) / 100;
            H4Dcontract_.buy.value(_bal)(_pusher);
            H4Dcontract_.sell(H4Dcontract_.balanceOf(address(this)));
            uint256 _tracker = H4Dcontract_.dividendsOf(address(this));
            while (_tracker >= _stop) 
            {
                H4Dcontract_.reinvest();
                H4Dcontract_.sell(H4Dcontract_.balanceOf(address(this)));
                _tracker = (_tracker.mul(81)) / 100;
            }
            H4Dcontract_.withdraw();
        } else {
            _compressedData = _compressedData.insert(1, 47, 47);
        }
        pushers_[_pusher].time = now;
        _compressedData = _compressedData.insert(now, 0, 14);
        _compressedData = _compressedData.insert(pushers_[_pusher].tracker, 15, 29);
        _compressedData = _compressedData.insert(pusherTracker_, 30, 44);
        _compressedData = _compressedData.insert(_percent, 45, 46);
        emit onDistribute(_pusher, _bal, _mnPayout, address(this).balance, _compressedData);
    }
}
