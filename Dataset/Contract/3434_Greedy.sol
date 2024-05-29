contract Greedy is Owned {
    uint public Round = 1;
    mapping(uint => uint) public RoundHeart;
    mapping(uint => uint) public RoundETH;  
    mapping(uint => uint) public RoundTime;
    mapping(uint => uint) public RoundPayMask;
    mapping(uint => address) public RoundLastGreedyMan;
    uint256 public Luckybuy;
    mapping(uint => mapping(address => uint)) public RoundMyHeart;
    mapping(uint => mapping(address => uint)) public RoundMyPayMask;
    mapping(address => uint) public MyreferredRevenue;
    uint256 public luckybuyTracker_ = 0;
    uint256 constant private RoundIncrease = 1 seconds;  
    uint256 constant private RoundMaxTime = 10 minutes;  
    uint256 public onwerfee;
    using SafeMath for *;
    using GreedyHeartCalcLong for uint256;
    event winnerEvent(address winnerAddr, uint256 newPot, uint256 round);
    event luckybuyEvent(address luckyAddr, uint256 amount, uint256 round);
    event buyheartEvent(address Addr, uint256 Heartamount, uint256 ethvalue, uint256 round, address ref);
    event referredEvent(address Addr, address RefAddr, uint256 ethvalue);
    event withdrawEvent(address Addr, uint256 ethvalue, uint256 Round);
    event withdrawRefEvent(address Addr, uint256 ethvalue);
    event withdrawOwnerEvent(uint256 ethvalue);
    function getHeartPrice() public view returns(uint256)
    {  
        return ( (RoundHeart[Round].add(1000000000000000000)).ethRec(1000000000000000000) );
    }
    function getMyRevenue(uint _round) public view returns(uint256)
    {
        return(  (((RoundPayMask[_round]).mul(RoundMyHeart[_round][msg.sender])) / (1000000000000000000)).sub(RoundMyPayMask[_round][msg.sender])  );
    }
    function getTimeLeft() public view returns(uint256)
    {
        if(RoundTime[Round] == 0 || RoundTime[Round] < now) 
            return 0;
        else 
            return( (RoundTime[Round]).sub(now) );
    }
    function updateTimer(uint256 _hearts) private
    {
        if(RoundTime[Round] == 0)
            RoundTime[Round] = RoundMaxTime.add(now);
        uint _newTime = (((_hearts) / (1000000000000000000)).mul(RoundIncrease)).add(RoundTime[Round]);
        if (_newTime < (RoundMaxTime).add(now))
            RoundTime[Round] = _newTime;
        else
            RoundTime[Round] = RoundMaxTime.add(now);
    }
    function buyHeart(address referred) public payable {
        require(msg.value >= 1000000000, "pocket lint: not a valid currency");
        require(msg.value <= 100000000000000000000000, "no vitalik, no");
        address _addr = msg.sender;
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        uint256 _hearts = (RoundETH[Round]).keysRec(msg.value);
        uint256 _pearn;
        require(_hearts >= 1000000000000000000);
        require(RoundTime[Round] > now || RoundTime[Round] == 0);
        updateTimer(_hearts);
        RoundHeart[Round] += _hearts;
        RoundMyHeart[Round][msg.sender] += _hearts;
        if (referred != address(0) && referred != msg.sender)
        {
             _pearn = (((msg.value.mul(30) / 100).mul(1000000000000000000)) / (RoundHeart[Round])).mul(_hearts)/ (1000000000000000000);
            onwerfee += (msg.value.mul(4) / 100);
            RoundETH[Round] += msg.value.mul(54) / 100;
            Luckybuy += msg.value.mul(2) / 100;
            MyreferredRevenue[referred] += (msg.value.mul(10) / 100);
            RoundPayMask[Round] += ((msg.value.mul(30) / 100).mul(1000000000000000000)) / (RoundHeart[Round]);
            RoundMyPayMask[Round][msg.sender] = (((RoundPayMask[Round].mul(_hearts)) / (1000000000000000000)).sub(_pearn)).add(RoundMyPayMask[Round][msg.sender]);
            emit referredEvent(msg.sender, referred, msg.value.mul(10) / 100);
        } else {
             _pearn = (((msg.value.mul(40) / 100).mul(1000000000000000000)) / (RoundHeart[Round])).mul(_hearts)/ (1000000000000000000);
            RoundETH[Round] += msg.value.mul(54) / 100;
            Luckybuy += msg.value.mul(2) / 100;
            onwerfee +=(msg.value.mul(4) / 100);
            RoundPayMask[Round] += ((msg.value.mul(40) / 100).mul(1000000000000000000)) / (RoundHeart[Round]);
            RoundMyPayMask[Round][msg.sender] = (((RoundPayMask[Round].mul(_hearts)) / (1000000000000000000)).sub(_pearn)).add(RoundMyPayMask[Round][msg.sender]);
        }
        if (msg.value >= 100000000000000000){
            luckybuyTracker_++;
            if (luckyBuy() == true)
            {
                msg.sender.transfer(Luckybuy);
                emit luckybuyEvent(msg.sender, Luckybuy, Round);
                luckybuyTracker_ = 0;
                Luckybuy = 0;
            }
        }
        RoundLastGreedyMan[Round] = msg.sender;
        emit buyheartEvent(msg.sender, _hearts, msg.value, Round, referred);
    }
    function win() public {
        require(now > RoundTime[Round] && RoundTime[Round] != 0);
        RoundLastGreedyMan[Round].transfer(RoundETH[Round]);
        emit winnerEvent(RoundLastGreedyMan[Round], RoundETH[Round], Round);
        Round++;
    }
    function withdraw(uint _round) public {
        uint _revenue = getMyRevenue(_round);
        uint _revenueRef = MyreferredRevenue[msg.sender];
        RoundMyPayMask[_round][msg.sender] += _revenue;
        MyreferredRevenue[msg.sender] = 0;
        msg.sender.transfer(_revenue + _revenueRef); 
        emit withdrawRefEvent( msg.sender, _revenue);
        emit withdrawEvent(msg.sender, _revenue, _round);
    }
    function withdrawOwner()  public onlyOwner {
        uint _revenue = onwerfee;
        msg.sender.transfer(_revenue);    
        onwerfee = 0;
        emit withdrawOwnerEvent(_revenue);
    }
    function luckyBuy() private view returns(bool)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));
        if((seed - ((seed / 1000) * 1000)) < luckybuyTracker_)
            return(true);
        else
            return(false);
    }
    function getFullround()public view returns(uint[] round,uint[] pot, address[] whowin,uint[] mymoney) {
        uint[] memory whichRound = new uint[](Round);
        uint[] memory totalPool = new uint[](Round);
        address[] memory winner = new address[](Round);
        uint[] memory myMoney = new uint[](Round);
        uint counter = 0;
        for (uint i = 1; i <= Round; i++) {
            whichRound[counter] = i;
            totalPool[counter] = RoundETH[i];
            winner[counter] = RoundLastGreedyMan[i];
            myMoney[counter] = getMyRevenue(i);
            counter++;
        }
        return (whichRound,totalPool,winner,myMoney);
    }
}
