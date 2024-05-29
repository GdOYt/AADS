contract GTO is ERC20Interface {
    uint8 public constant decimals = 5;
    string public constant symbol = "GTO";
    string public constant name = "GTO";
    bool public _selling = false; 
    uint256 public _totalSupply = 10 ** 14;  
    uint256 public _originalBuyPrice = 45 * 10**7;  
    address public owner;
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;
    mapping(address => bool) private approvedInvestorList;
    mapping(address => uint256) private deposit;
    address[] private buyers;
    uint8 public _icoPercent = 10;
    uint256 public _icoSupply = _totalSupply * _icoPercent / 100;
    uint256 public _minimumBuy = 3 * 10 ** 17;
    uint256 public _maximumBuy = 30 * 10 ** 18;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onSale() {
        require(_selling && (_icoSupply > 0) );
        _;
    }
    modifier validInvestor() {
        require(approvedInvestorList[msg.sender]);
        _;
    }
    modifier validValue(){
        require ( (msg.value >= _minimumBuy) &&
                ( (deposit[msg.sender] + msg.value) <= _maximumBuy) );
        _;
    }
    modifier validRange(uint256 a, uint256 b){
        require ( (a>=0 && a<=b) &&
                  (b<buyers.length) );
        _;
    }
    function()
        public
        payable {
        buyGifto();
    }
    function buyGifto()
        public
        payable
        onSale
        validValue
        validInvestor {
        if (deposit[msg.sender] == 0){
            buyers.push(msg.sender);
        }
        deposit[msg.sender] += msg.value;
        owner.transfer(msg.value);
    }
    function GTO() 
        public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
    }
    function totalSupply()
        public 
        constant 
        returns (uint256) {
        return _totalSupply;
    }
    function turnOnSale() onlyOwner 
        public {
        _selling = true;
    }
    function turnOffSale() onlyOwner 
        public {
        _selling = false;
    }
    function setIcoPercent(uint8 newIcoPercent)
        public 
        onlyOwner {
        _icoPercent = newIcoPercent;
        _icoSupply = _totalSupply * _icoPercent / 100;
    }
    function setMaximumBuy(uint256 newMaximumBuy)
        public 
        onlyOwner {
        _maximumBuy = newMaximumBuy;
    }
    function setBuyPrice(uint256 newBuyPrice) 
        onlyOwner 
        public {
        require(newBuyPrice>0);
        _originalBuyPrice = newBuyPrice;  
        _maximumBuy = 10**18 * 10000000000 /_originalBuyPrice;
    }
    function balanceOf(address _addr) 
        public
        constant 
        returns (uint256) {
        return balances[_addr];
    }
    function isApprovedInvestor(address _addr)
        public
        constant
        returns (bool) {
        return approvedInvestorList[_addr];
    }
    function getBuyers()
    public
    constant
    returns(address[]){
        return buyers;
    }
    function getDeposit(address _addr)
        public
        constant
        returns(uint256){
        return deposit[_addr];
    }
    function addInvestorList(address[] newInvestorList)
        onlyOwner
        public {
        for (uint256 i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }
    function removeInvestorList(address[] investorList)
        onlyOwner
        public {
        for (uint256 i = 0; i < investorList.length; i++){
            approvedInvestorList[investorList[i]] = false;
        }
    }
    function deliveryToken(uint256 a, uint256 b)
        public
        onlyOwner
        validRange(a, b) {
        require(balances[owner] >= _icoSupply);
        for (uint256 i = a; i <= b; i++){
            if(approvedInvestorList[buyers[i]]){
                uint256 requestedUnits = (deposit[buyers[i]] * _originalBuyPrice) / 10**18;
                if(requestedUnits <= _icoSupply && requestedUnits > 0 ){
                    balances[owner] -= requestedUnits;
                    balances[buyers[i]] += requestedUnits;
                    _icoSupply -= requestedUnits;
                    Transfer(owner, buyers[i], requestedUnits);
                    deposit[buyers[i]] = 0;
                }
            }
        }
    }
    function transfer(address _to, uint256 _amount)
        public 
        returns (bool) {
        if ( (balances[msg.sender] >= _amount) &&
             (_amount >= 0) && 
             (balances[_to] + _amount > balances[_to]) ) {  
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
    public
    returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    function approve(address _spender, uint256 _amount) 
        public
        returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    function allowance(address _owner, address _spender) 
        public
        constant 
        returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function withdraw() onlyOwner 
        public 
        returns (bool) {
        return owner.send(this.balance);
    }
}
