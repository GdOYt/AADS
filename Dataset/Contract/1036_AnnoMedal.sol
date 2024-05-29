contract AnnoMedal is ERC20Interface, Administration, SafeMath {
    event MedalTransfer(address indexed from, address indexed to, uint tokens);
    string public medalSymbol;
    string public medalName;
    uint8 public medalDecimals;
    uint public _medalTotalSupply;
    mapping(address => uint) medalBalances;
    mapping(address => bool) medalFreezed;
    mapping(address => uint) medalFreezeAmount;
    mapping(address => uint) medalUnlockTime;
    function AnnoMedal() public {
        medalSymbol = "CPLD";
        medalName = "Anno Medal";
        medalDecimals = 0;
        _medalTotalSupply = 1000000;
        medalBalances[adminAddress] = _medalTotalSupply;
        MedalTransfer(address(0), adminAddress, _medalTotalSupply);
    }
    function medalTotalSupply() public constant returns (uint) {
        return _medalTotalSupply  - medalBalances[address(0)];
    }
    function medalBalanceOf(address tokenOwner) public constant returns (uint balance) {
        return medalBalances[tokenOwner];
    }
    function medalTransfer(address to, uint tokens) public whenNotPaused returns (bool success) {
        if(medalFreezed[msg.sender] == false){
            medalBalances[msg.sender] = safeSub(medalBalances[msg.sender], tokens);
            medalBalances[to] = safeAdd(medalBalances[to], tokens);
            MedalTransfer(msg.sender, to, tokens);
        } else {
            if(medalBalances[msg.sender] > medalFreezeAmount[msg.sender]) {
                require(tokens <= safeSub(medalBalances[msg.sender], medalFreezeAmount[msg.sender]));
                medalBalances[msg.sender] = safeSub(medalBalances[msg.sender], tokens);
                medalBalances[to] = safeAdd(medalBalances[to], tokens);
                MedalTransfer(msg.sender, to, tokens);
            }
        }
        return true;
    }
    function mintMedal(uint amount) public onlyAdmin {
        medalBalances[msg.sender] = safeAdd(medalBalances[msg.sender], amount);
        _medalTotalSupply = safeAdd(_medalTotalSupply, amount);
    }
    function burnMedal(uint amount) public onlyAdmin {
        medalBalances[msg.sender] = safeSub(medalBalances[msg.sender], amount);
        _medalTotalSupply = safeSub(_medalTotalSupply, amount);
    }
    function medalFreeze(address user, uint amount, uint period) public onlyAdmin {
        require(medalBalances[user] >= amount);
        medalFreezed[user] = true;
        medalUnlockTime[user] = uint(now) + period;
        medalFreezeAmount[user] = amount;
    }
    function _medalFreeze(uint amount) internal {
        require(medalFreezed[msg.sender] == false);
        require(medalBalances[msg.sender] >= amount);
        medalFreezed[msg.sender] = true;
        medalUnlockTime[msg.sender] = uint(-1);
        medalFreezeAmount[msg.sender] = amount;
    }
    function medalUnFreeze() public whenNotPaused {
        require(medalFreezed[msg.sender] == true);
        require(medalUnlockTime[msg.sender] < uint(now));
        medalFreezed[msg.sender] = false;
        medalFreezeAmount[msg.sender] = 0;
    }
    function _medalUnFreeze(uint _amount) internal {
        require(medalFreezed[msg.sender] == true);
        medalUnlockTime[msg.sender] = 0;
        medalFreezed[msg.sender] = false;
        medalFreezeAmount[msg.sender] = safeSub(medalFreezeAmount[msg.sender], _amount);
    }
    function medalIfFreeze(address user) public view returns (
        bool check, 
        uint amount, 
        uint timeLeft
    ) {
        check = medalFreezed[user];
        amount = medalFreezeAmount[user];
        timeLeft = medalUnlockTime[user] - uint(now);
    }
}
