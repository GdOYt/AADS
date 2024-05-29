contract BinaryOption {
    address public namiCrowdSaleAddr;
    address public escrow;
    address public namiMultiSigWallet;
    Session public session;
    uint public timeInvestInMinute = 15;
    uint public timeOneSession = 20;
    uint public sessionId = 1;
    uint public rateWin = 100;
    uint public rateLoss = 20;
    uint public rateFee = 5;
    uint public constant MAX_INVESTOR = 20;
    uint public minimunEth = 10000000000000000;  
    event SessionOpen(uint timeOpen, uint indexed sessionId);
    event InvestClose(uint timeInvestClose, uint priceOpen, uint indexed sessionId);
    event Invest(address indexed investor, bool choose, uint amount, uint timeInvest, uint indexed sessionId);
    event SessionClose(uint timeClose, uint indexed sessionId, uint priceClose, uint nacPrice, uint rateWin, uint rateLoss, uint rateFee);
    event Deposit(address indexed sender, uint value);
    function() public payable {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }
    struct Session {
        uint priceOpen;
        uint priceClose;
        uint timeOpen;
        bool isReset;
        bool isOpen;
        bool investOpen;
        uint investorCount;
        mapping(uint => address) investor;
        mapping(uint => bool) win;
        mapping(uint => uint) amountInvest;
    }
    function BinaryOption(address _namiCrowdSale, address _escrow, address _namiMultiSigWallet) public {
        require(_namiCrowdSale != 0x0 && _escrow != 0x0);
        namiCrowdSaleAddr = _namiCrowdSale;
        escrow = _escrow;
        namiMultiSigWallet = _namiMultiSigWallet;
    }
    modifier onlyEscrow() {
        require(msg.sender==escrow);
        _;
    }
    modifier onlyNamiMultisig() {
        require(msg.sender == namiMultiSigWallet);
        _;
    }
    function changeEscrow(address _escrow) public
        onlyNamiMultisig
    {
        require(_escrow != 0x0);
        escrow = _escrow;
    }
    function changeMinEth(uint _minimunEth) public 
        onlyEscrow
    {
        require(_minimunEth != 0);
        minimunEth = _minimunEth;
    }
    function changeTimeInvest(uint _timeInvest)
        public
        onlyEscrow
    {
        require(!session.isOpen && _timeInvest < timeOneSession);
        timeInvestInMinute = _timeInvest;
    }
    function changeTimeOneSession(uint _timeOneSession) 
        public
        onlyEscrow
    {
        require(!session.isOpen && _timeOneSession > timeInvestInMinute);
        timeOneSession = _timeOneSession;
    }
    function changeRateWin(uint _rateWin)
        public
        onlyEscrow
    {
        require(!session.isOpen);
        rateWin = _rateWin;
    }
    function changeRateLoss(uint _rateLoss)
        public
        onlyEscrow
    {
        require(!session.isOpen);
        rateLoss = _rateLoss;
    }
    function changeRateFee(uint _rateFee)
        public
        onlyEscrow
    {
        require(!session.isOpen);
        rateFee = _rateFee;
    }
    function withdrawEther(uint _amount) public
        onlyEscrow
    {
        require(namiMultiSigWallet != 0x0);
        if (this.balance > 0) {
            namiMultiSigWallet.transfer(_amount);
        }
    }
    function safeWithdraw(address _withdraw, uint _amount) public
        onlyEscrow
    {
        NamiMultiSigWallet namiWallet = NamiMultiSigWallet(namiMultiSigWallet);
        if (namiWallet.isOwner(_withdraw)) {
            _withdraw.transfer(_amount);
        }
    }
    function getInvestors()
        public
        view
        returns (address[20])
    {
        address[20] memory listInvestor;
        for (uint i = 0; i < MAX_INVESTOR; i++) {
            listInvestor[i] = session.investor[i];
        }
        return listInvestor;
    }
    function getChooses()
        public
        view
        returns (bool[20])
    {
        bool[20] memory listChooses;
        for (uint i = 0; i < MAX_INVESTOR; i++) {
            listChooses[i] = session.win[i];
        }
        return listChooses;
    }
    function getAmount()
        public
        view
        returns (uint[20])
    {
        uint[20] memory listAmount;
        for (uint i = 0; i < MAX_INVESTOR; i++) {
            listAmount[i] = session.amountInvest[i];
        }
        return listAmount;
    }
    function resetSession()
        public
        onlyEscrow
    {
        require(!session.isReset && !session.isOpen);
        session.priceOpen = 0;
        session.priceClose = 0;
        session.isReset = true;
        session.isOpen = false;
        session.investOpen = false;
        session.investorCount = 0;
        for (uint i = 0; i < MAX_INVESTOR; i++) {
            session.investor[i] = 0x0;
            session.win[i] = false;
            session.amountInvest[i] = 0;
        }
    }
    function openSession ()
        public
        onlyEscrow
    {
        require(session.isReset && !session.isOpen);
        session.isReset = false;
        session.investOpen = true;
        session.timeOpen = now;
        session.isOpen = true;
        SessionOpen(now, sessionId);
    }
    function invest (bool _choose)
        public
        payable
    {
        require(msg.value >= minimunEth && session.investOpen);  
        require(now < (session.timeOpen + timeInvestInMinute * 1 minutes));
        require(session.investorCount < MAX_INVESTOR);
        session.investor[session.investorCount] = msg.sender;
        session.win[session.investorCount] = _choose;
        session.amountInvest[session.investorCount] = msg.value;
        session.investorCount += 1;
        Invest(msg.sender, _choose, msg.value, now, sessionId);
    }
    function closeInvest (uint _priceOpen) 
        public
        onlyEscrow
    {
        require(_priceOpen != 0 && session.investOpen);
        require(now > (session.timeOpen + timeInvestInMinute * 1 minutes));
        session.investOpen = false;
        session.priceOpen = _priceOpen;
        InvestClose(now, _priceOpen, sessionId);
    }
    function getEtherToBuy (uint _ether, bool _status)
        public
        view
        returns (uint)
    {
        if (_status) {
            return _ether * rateWin / 100;
        } else {
            return _ether * rateLoss / 100;
        }
    }
    function closeSession (uint _priceClose)
        public
        onlyEscrow
    {
        require(_priceClose != 0 && now > (session.timeOpen + timeOneSession * 1 minutes));
        require(!session.investOpen && session.isOpen);
        session.priceClose = _priceClose;
        bool result = (_priceClose>session.priceOpen)?true:false;
        uint etherToBuy;
        NamiCrowdSale namiContract = NamiCrowdSale(namiCrowdSaleAddr);
        uint price = namiContract.getPrice();
        require(price != 0);
        for (uint i = 0; i < session.investorCount; i++) {
            if (session.win[i]==result) {
                etherToBuy = (session.amountInvest[i] - session.amountInvest[i] * rateFee / 100) * rateWin / 100;
                uint etherReturn = session.amountInvest[i] - session.amountInvest[i] * rateFee / 100;
                (session.investor[i]).transfer(etherReturn);
            } else {
                etherToBuy = (session.amountInvest[i] - session.amountInvest[i] * rateFee / 100) * rateLoss / 100;
            }
            namiContract.buy.value(etherToBuy)(session.investor[i]);
            session.investor[i] = 0x0;
            session.win[i] = false;
            session.amountInvest[i] = 0;
        }
        session.isOpen = false;
        SessionClose(now, sessionId, _priceClose, price, rateWin, rateLoss, rateFee);
        sessionId += 1;
        session.priceOpen = 0;
        session.priceClose = 0;
        session.isReset = true;
        session.investOpen = false;
        session.investorCount = 0;
    }
}
