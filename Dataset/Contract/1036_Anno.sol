contract Anno is AnnoToken {
    event MembershipUpdate(address indexed member, uint indexed level);
    event MembershipCancel(address indexed member);
    event AnnoTradeCreated(uint indexed tradeId, bool indexed ifMedal, uint medal, uint token);
    event TradeCancel(uint indexed tradeId);
    event TradeComplete(uint indexed tradeId, address indexed buyer, address indexed seller, uint medal, uint token);
    event Mine(address indexed miner, uint indexed salary);
    mapping (address => uint) MemberToLevel;
    mapping (address => uint) MemberToMedal;
    mapping (address => uint) MemberToToken;
    mapping (address => uint) MemberToTime;
    uint public period = 14 days;
    uint[5] public boardMember =[
        0,
        500,
        2500,
        25000,
        50000
    ];
    uint[5] public salary = [
        0,
        1151000000000000000000,
        5753000000000000000000,
        57534000000000000000000,
        115068000000000000000000
    ];
    struct AnnoTrade {
        address seller;
        bool ifMedal;
        uint medal;
        uint token;
    }
    AnnoTrade[] annoTrades;
    function boardMemberApply(uint _level) public whenNotPaused {
        require(_level > 0 && _level <= 4);
        require(medalBalances[msg.sender] >= boardMember[_level]);
        _medalFreeze(boardMember[_level]);
        MemberToLevel[msg.sender] = _level;
        if(MemberToTime[msg.sender] == 0) {
            MemberToTime[msg.sender] = uint(now);
        }
        MembershipUpdate(msg.sender, _level);
    }
    function getBoardMember(address _member) public view returns (
        uint level,
        uint timeLeft
    ) {
        level = MemberToLevel[_member];
        if(MemberToTime[_member] > uint(now)) {
            timeLeft = safeSub(MemberToTime[_member], uint(now));
        } else {
            timeLeft = 0;
        }
    }
    function boardMemberCancel() public whenNotPaused {
        require(MemberToLevel[msg.sender] > 0);
        _medalUnFreeze(boardMember[MemberToLevel[msg.sender]]);
        MemberToLevel[msg.sender] = 0;
        MembershipCancel(msg.sender);
    }
    function createAnnoTrade(bool _ifMedal, uint _medal, uint _token) public whenNotPaused returns (uint) {
        if(_ifMedal) {
            require(medalBalances[msg.sender] >= _medal);
            medalBalances[msg.sender] = safeSub(medalBalances[msg.sender], _medal);
            MemberToMedal[msg.sender] = _medal;
            AnnoTrade memory anno = AnnoTrade({
               seller: msg.sender,
               ifMedal:_ifMedal,
               medal: _medal,
               token: _token
            });
            uint newMedalTradeId = annoTrades.push(anno) - 1;
            AnnoTradeCreated(newMedalTradeId, _ifMedal, _medal, _token);
            return newMedalTradeId;
        } else {
            require(balances[msg.sender] >= _token);
            balances[msg.sender] = safeSub(balances[msg.sender], _token);
            MemberToToken[msg.sender] = _token;
            AnnoTrade memory _anno = AnnoTrade({
               seller: msg.sender,
               ifMedal:_ifMedal,
               medal: _medal,
               token: _token
            });
            uint newTokenTradeId = annoTrades.push(_anno) - 1;
            AnnoTradeCreated(newTokenTradeId, _ifMedal, _medal, _token);
            return newTokenTradeId;
        }
    }
    function cancelTrade(uint _tradeId) public whenNotPaused {
        AnnoTrade memory anno = annoTrades[_tradeId];
        require(anno.seller == msg.sender);
        if(anno.ifMedal){
            medalBalances[msg.sender] = safeAdd(medalBalances[msg.sender], anno.medal);
            MemberToMedal[msg.sender] = 0;
        } else {
            balances[msg.sender] = safeAdd(balances[msg.sender], anno.token);
            MemberToToken[msg.sender] = 0;
        }
        delete annoTrades[_tradeId];
        TradeCancel(_tradeId);
    }
    function trade(uint _tradeId) public whenNotPaused {
        AnnoTrade memory anno = annoTrades[_tradeId];
        if(anno.ifMedal){
            medalBalances[msg.sender] = safeAdd(medalBalances[msg.sender], anno.medal);
            MemberToMedal[anno.seller] = 0;
            transfer(anno.seller, anno.token);
            delete annoTrades[_tradeId];
            TradeComplete(_tradeId, msg.sender, anno.seller, anno.medal, anno.token);
        } else {
            balances[msg.sender] = safeAdd(balances[msg.sender], anno.token);
            MemberToToken[anno.seller] = 0;
            medalTransfer(anno.seller, anno.medal);
            delete annoTrades[_tradeId];
            TradeComplete(_tradeId, msg.sender, anno.seller, anno.medal, anno.token);
        }
    }
    function mine() public whenNotPaused {
        uint level = MemberToLevel[msg.sender];
        require(MemberToTime[msg.sender] < uint(now)); 
        require(level > 0);
        _mint(salary[level], msg.sender);
        MemberToTime[msg.sender] = safeAdd(MemberToTime[msg.sender], period);
        Mine(msg.sender, salary[level]);
    }
    function setBoardMember(uint one, uint two, uint three, uint four) public onlyAdmin {
        boardMember[1] = one;
        boardMember[2] = two;
        boardMember[3] = three;
        boardMember[4] = four;
    }
    function setSalary(uint one, uint two, uint three, uint four) public onlyAdmin {
        salary[1] = one;
        salary[2] = two;
        salary[3] = three;
        salary[4] = four;
    }
    function setPeriod(uint time) public onlyAdmin {
        period = time;
    }
    function getTrade(uint _tradeId) public view returns (
        address seller,
        bool ifMedal,
        uint medal,
        uint token 
    ) {
        AnnoTrade memory _anno = annoTrades[_tradeId];
        seller = _anno.seller;
        ifMedal = _anno.ifMedal;
        medal = _anno.medal;
        token = _anno.token;
    }
    function WhoIsTheContractMaster() public pure returns (string) {
        return "Alexander The Exlosion";
    }
}
