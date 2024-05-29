contract QCOToken is StandardToken {
    enum States {
        Initial,  
        ValuationSet,
        Ico,  
        Aborted,  
        Operational,  
        Paused          
    }
    mapping(address => uint256) public ethPossibleRefunds;
    uint256 public soldTokens;
    string public constant name = "Qravity Coin Token";
    string public constant symbol = "QCO";
    uint8 public constant decimals = 18;
    mapping(address => bool) public whitelist;
    address public stateControl;
    address public whitelistControl;
    address public withdrawControl;
    address public tokenAssignmentControl;
    address public teamWallet;
    address public reserves;
    States public state;
    uint256 public endBlock;
    uint256 public ETH_QCO;  
    uint256 constant pointMultiplier = 1e18;  
    uint256 public constant maxTotalSupply = 1000000000 * pointMultiplier;  
    uint256 public constant percentForSale = 50;
    Bonus.BonusData bonusData;
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    bool public mintingFinished = false;
    uint256 public pauseOffset = 0;
    uint256 public pauseLastStart = 0;
    function QCOToken(
        address _stateControl
    , address _whitelistControl
    , address _withdrawControl
    , address _tokenAssignmentControl
    , address _teamControl
    , address _reserves)
    public
    {
        stateControl = _stateControl;
        whitelistControl = _whitelistControl;
        withdrawControl = _withdrawControl;
        tokenAssignmentControl = _tokenAssignmentControl;
        moveToState(States.Initial);
        endBlock = 0;
        ETH_QCO = 0;
        totalSupply = maxTotalSupply;
        soldTokens = 0;
        Bonus.initBonus(bonusData);
        teamWallet = address(new QravityTeamTimelock(this, _teamControl));
        reserves = _reserves;
        balances[reserves] = totalSupply;
        Mint(reserves, totalSupply);
        Transfer(0x0, reserves, totalSupply);
    }
    event Whitelisted(address addr);
    event StateTransition(States oldState, States newState);
    modifier onlyWhitelist() {
        require(msg.sender == whitelistControl);
        _;
    }
    modifier onlyStateControl() {
        require(msg.sender == stateControl);
        _;
    }
    modifier onlyTokenAssignmentControl() {
        require(msg.sender == tokenAssignmentControl);
        _;
    }
    modifier onlyWithdraw() {
        require(msg.sender == withdrawControl);
        _;
    }
    modifier requireState(States _requiredState) {
        require(state == _requiredState);
        _;
    }
    function() payable
    public
    requireState(States.Ico)
    {
        require(whitelist[msg.sender] == true);
        require(msg.value > 0);
        require(msg.data.length < 4);
        require(block.number < endBlock);
        uint256 soldToTuserWithBonus = calcBonus(msg.value);
        issueTokensToUser(msg.sender, soldToTuserWithBonus);
        ethPossibleRefunds[msg.sender] = ethPossibleRefunds[msg.sender].add(msg.value);
    }
    function issueTokensToUser(address beneficiary, uint256 amount)
    internal
    {
        uint256 soldTokensAfterInvestment = soldTokens.add(amount);
        require(soldTokensAfterInvestment <= maxTotalSupply.mul(percentForSale).div(100));
        balances[beneficiary] = balances[beneficiary].add(amount);
        balances[reserves] = balances[reserves].sub(amount);
        soldTokens = soldTokensAfterInvestment;
        Transfer(reserves, beneficiary, amount);
    }
    function getCurrentBonusFactor()
    public view
    returns (uint256 factor)
    {
        return Bonus.getBonusFactor(now - pauseOffset, bonusData);
    }
    function getNextCutoffTime()
    public view returns (uint timestamp)
    {
        return Bonus.getFollowingCutoffTime(now - pauseOffset, bonusData);
    }
    function calcBonus(uint256 weiAmount)
    constant
    public
    returns (uint256 resultingTokens)
    {
        uint256 basisTokens = weiAmount.mul(ETH_QCO);
        uint256 perMillBonus = getCurrentBonusFactor();
        return basisTokens.mul(per_mill + perMillBonus).div(per_mill);
    }
    uint256 constant per_mill = 1000;
    function moveToState(States _newState)
    internal
    {
        StateTransition(state, _newState);
        state = _newState;
    }
    function updateEthICOVariables(uint256 _new_ETH_QCO, uint256 _newEndBlock)
    public
    onlyStateControl
    {
        require(state == States.Initial || state == States.ValuationSet);
        require(_new_ETH_QCO > 0);
        require(block.number < _newEndBlock);
        endBlock = _newEndBlock;
        ETH_QCO = _new_ETH_QCO;
        moveToState(States.ValuationSet);
    }
    function startICO()
    public
    onlyStateControl
    requireState(States.ValuationSet)
    {
        require(block.number < endBlock);
        moveToState(States.Ico);
    }
    function addPresaleAmount(address beneficiary, uint256 amount)
    public
    onlyTokenAssignmentControl
    {
        require(state == States.ValuationSet || state == States.Ico);
        issueTokensToUser(beneficiary, amount);
    }
    function endICO()
    public
    onlyStateControl
    requireState(States.Ico)
    {
        burnAndFinish();
        moveToState(States.Operational);
    }
    function anyoneEndICO()
    public
    requireState(States.Ico)
    {
        require(block.number > endBlock);
        burnAndFinish();
        moveToState(States.Operational);
    }
    function burnAndFinish()
    internal
    {
        totalSupply = soldTokens.mul(100).div(percentForSale);
        uint256 teamAmount = totalSupply.mul(22).div(100);
        balances[teamWallet] = teamAmount;
        Transfer(reserves, teamWallet, teamAmount);
        uint256 reservesAmount = totalSupply.sub(soldTokens).sub(teamAmount);
        Transfer(reserves, 0x0, balances[reserves].sub(reservesAmount).sub(teamAmount));
        balances[reserves] = reservesAmount;
        mintingFinished = true;
        MintFinished();
    }
    function addToWhitelist(address _whitelisted)
    public
    onlyWhitelist
    {
        whitelist[_whitelisted] = true;
        Whitelisted(_whitelisted);
    }
    function pause()
    public
    onlyStateControl
    requireState(States.Ico)
    {
        moveToState(States.Paused);
        pauseLastStart = now;
    }
    function abort()
    public
    onlyStateControl
    requireState(States.Paused)
    {
        moveToState(States.Aborted);
    }
    function resumeICO()
    public
    onlyStateControl
    requireState(States.Paused)
    {
        moveToState(States.Ico);
        pauseOffset = pauseOffset + (now - pauseLastStart);
    }
    function requestRefund()
    public
    requireState(States.Aborted)
    {
        require(ethPossibleRefunds[msg.sender] > 0);
        uint256 payout = ethPossibleRefunds[msg.sender];
        ethPossibleRefunds[msg.sender] = 0;
        msg.sender.transfer(payout);
    }
    function requestPayout(uint _amount)
    public
    onlyWithdraw  
    requireState(States.Operational)
    {
        msg.sender.transfer(_amount);
    }
    function rescueToken(ERC20Basic _foreignToken, address _to)
    public
    onlyTokenAssignmentControl
    {
        _foreignToken.transfer(_to, _foreignToken.balanceOf(this));
    }
    function transfer(address _to, uint256 _value)
    public
    requireState(States.Operational)
    returns (bool success) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value)
    public
    requireState(States.Operational)
    returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }
}
