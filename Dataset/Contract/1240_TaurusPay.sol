contract TaurusPay is StandardToken {
    string public constant name = "TaurusPay";
    string public constant symbol = "TAPT";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 950 * 10**6 * (10**uint256(decimals));
    address public owner;
    mapping (address => bool) public contractUsers;
    bool public mintingFinished;
    uint256 public tokenAllocated = 0;
    mapping (address => uint) public countClaimsToken;
    uint256 public priceToken = 950000;
    uint256 public priceClaim = 0.0005 ether;
    uint256 public numberClaimToken = 200 * (10**uint256(decimals));
    uint256 public startTimeDay = 50400;
    uint256 public endTimeDay = 51300;
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event MinWeiLimitReached(address indexed sender, uint256 weiAmount);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    constructor(address _owner) public {
        totalSupply = INITIAL_SUPPLY;
        owner = _owner;
        balances[owner] = INITIAL_SUPPLY;
        transfersEnabled = true;
        mintingFinished = false;
    }
    function() payable public {
        buyTokens(msg.sender);
    }
    function buyTokens(address _investor) public payable returns (uint256){
        require(_investor != address(0));
        uint256 weiAmount = msg.value;
        uint256 tokens = validPurchaseTokens(weiAmount);
        if (tokens == 0) {revert();}
        tokenAllocated = tokenAllocated.add(tokens);
        mint(_investor, tokens, owner);
        emit TokenPurchase(_investor, weiAmount, tokens);
        owner.transfer(weiAmount);
        return tokens;
    }
    function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
        uint256 addTokens = _weiAmount.mul(priceToken);
        if (_weiAmount < 0.01 ether) {
            emit MinWeiLimitReached(msg.sender, _weiAmount);
            return 0;
        }
        if (tokenAllocated.add(addTokens) > balances[owner]) {
            emit TokenLimitReached(tokenAllocated, addTokens);
            return 0;
        }
        return addTokens;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
    function changeOwner(address _newOwner) onlyOwner public returns (bool){
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }
    function mint(address _to, uint256 _amount, address _owner) canMint internal returns (bool) {
        require(_to != address(0));
        require(_amount <= balances[owner]);
        require(!mintingFinished);
        balances[_to] = balances[_to].add(_amount);
        balances[_owner] = balances[_owner].sub(_amount);
        emit Mint(_to, _amount);
        emit Transfer(_owner, _to, _amount);
        return true;
    }
    function claim() canMint public payable returns (bool) {
        uint256 currentTime = now;
        require(validPurchaseTime(currentTime));
        require(msg.value >= priceClaim);
        address beneficiar = msg.sender;
        require(beneficiar != address(0));
        require(!mintingFinished);
        uint256 amount = calcAmount(beneficiar);
        require(amount <= balances[owner]);
        balances[beneficiar] = balances[beneficiar].add(amount);
        balances[owner] = balances[owner].sub(amount);
        tokenAllocated = tokenAllocated.add(amount);
        owner.transfer(msg.value);
        emit Mint(beneficiar, amount);
        emit Transfer(owner, beneficiar, amount);
        return true;
    }
    function calcAmount(address _beneficiar) canMint internal returns (uint256 amount) {
        if (countClaimsToken[_beneficiar] == 0) {
            countClaimsToken[_beneficiar] = 1;
        }
        if (countClaimsToken[_beneficiar] >= 22) {
            return 0;
        }
        uint step = countClaimsToken[_beneficiar];
        amount = numberClaimToken.mul(105 - 5*step).div(100);
        countClaimsToken[_beneficiar] = countClaimsToken[_beneficiar].add(1);
    }
    function validPurchaseTime(uint256 _currentTime) canMint public view returns (bool) {
        uint256 dayTime = _currentTime % 1 days;
        if (startTimeDay <= dayTime && dayTime <=  endTimeDay) {
            return true;
        }
        return false;
    }
    function changeTime(uint256 _newStartTimeDay, uint256 _newEndTimeDay) public {
        require(0 < _newStartTimeDay && 0 < _newEndTimeDay);
        startTimeDay = _newStartTimeDay;
        endTimeDay = _newEndTimeDay;
    }
    function claimTokensToOwner(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        TaurusPay token = TaurusPay(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        emit Transfer(_token, owner, balance);
    }
    function setPriceClaim(uint256 _newPriceClaim) external onlyOwner {
        require(_newPriceClaim > 0);
        priceClaim = _newPriceClaim;
    }
    function setNumberClaimToken(uint256 _newNumClaimToken) external onlyOwner {
        require(_newNumClaimToken > 0);
        numberClaimToken = _newNumClaimToken;
    }
}
