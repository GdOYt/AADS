contract BouleICO is Ownable{
    uint public startTime;              
    uint public secondPriceTime;        
    uint public thirdPriceTime;         
    uint public fourthPriceTime;        
    uint public endTime;                
    address public bouleDevMultisig;    
    uint public totalCollected = 0;     
    bool public saleStopped = false;    
    bool public saleFinalized = false;  
    BouleToken public token;            
    MultiSigWallet wallet;              
    uint constant public minInvestment = 0.1 ether;     
    mapping (address => bool) public whitelist;
    event NewBuyer(address indexed holder, uint256 bouAmount, uint256 amount);
    event Whitelisted(address addr, bool status);
    function BouleICO (
    address _token,
    address _bouleDevMultisig,
    uint _startTime,
    uint _secondPriceTime,
    uint _thirdPriceTime,
    uint _fourthPriceTime,
    uint _endTime
    )
    {
        if (_startTime >= _endTime) throw;
        token = BouleToken(_token);
        bouleDevMultisig = _bouleDevMultisig;
        wallet = MultiSigWallet(bouleDevMultisig);
        startTime = _startTime;
        secondPriceTime = _secondPriceTime;
        thirdPriceTime = _thirdPriceTime;
        fourthPriceTime = _fourthPriceTime;
        endTime = _endTime;
    }
    function setWhitelistStatus(address addr, bool status)
    onlyOwner {
        whitelist[addr] = status;
        Whitelisted(addr, status);
    }
    function getPrice() constant public returns (uint256) {
        var time = getNow();
        if(time < startTime){
            return 1400;
        }
        if(time < secondPriceTime){
            return 1200;  
        }
        if(time < thirdPriceTime){
            return 1150;  
        }
        if(time < fourthPriceTime){
            return 1100;  
        }
        return 1050;  
    }
    function getTokensLeft() public constant returns (uint) {
        return token.balanceOf(this);
    }
    function () public payable {
        doPayment(msg.sender);
    }
    function doPayment(address _owner)
    only_during_sale_period_or_whitelisted(_owner)
    only_sale_not_stopped
    non_zero_address(_owner)
    minimum_value(minInvestment)
    internal {
        uint256 tokenAmount = SafeMath.mul(msg.value, getPrice());
        if(tokenAmount > getTokensLeft()) {
            throw;
        }
        token.transfer(_owner, tokenAmount);
        totalCollected = SafeMath.add(totalCollected, msg.value);
        NewBuyer(_owner, tokenAmount, msg.value);
    }
    function emergencyStopSale()
    only_sale_not_stopped
    onlyOwner
    public {
        saleStopped = true;
    }
    function restartSale()
    only_during_sale_period
    only_sale_stopped
    onlyOwner
    public {
        saleStopped = false;
    }
    function moveFunds()
    onlyOwner
    public {
        if (!wallet.send(this.balance)) throw;
    }
    function finalizeSale()
    only_after_sale
    onlyOwner
    public {
        doFinalizeSale();
    }
    function doFinalizeSale()
    internal {
        if (!wallet.send(this.balance)) throw;
        token.transfer(bouleDevMultisig, getTokensLeft());
        saleFinalized = true;
        saleStopped = true;
    }
    function getNow() internal constant returns (uint) {
        return now;
    }
    modifier only(address x) {
        if (msg.sender != x) throw;
        _;
    }
    modifier only_during_sale_period {
        if (getNow() < startTime) throw;
        if (getNow() >= endTime) throw;
        _;
    }
    modifier only_during_sale_period_or_whitelisted(address x) {
        if (getNow() < startTime && !whitelist[x]) throw;
        if (getNow() >= endTime) throw;
        _;
    }
    modifier only_after_sale {
        if (getNow() < endTime) throw;
        _;
    }
    modifier only_sale_stopped {
        if (!saleStopped) throw;
        _;
    }
    modifier only_sale_not_stopped {
        if (saleStopped) throw;
        _;
    }
    modifier non_zero_address(address x) {
        if (x == 0) throw;
        _;
    }
    modifier minimum_value(uint256 x) {
        if (msg.value < x) throw;
        _;
    }
}
