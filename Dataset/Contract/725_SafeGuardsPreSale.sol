contract SafeGuardsPreSale is FinalizableCrowdsale, CappedCrowdsale {
    using SafeMath for uint256;
    uint256 public tokensSold;
    uint256 public minimumGoal;
    uint public loadedRefund;
    uint public weiRefunded;
    mapping (address => uint) public boughtAmountOf;
    uint256 constant public minimumAmountWei = 1e16;
    uint256 public presaleTransfersPaused = now + 180 days;
    uint256 public presaleBurnPaused = now + 180 days;
    uint constant public preSaleBonus1Time = 1535155200; 
    uint constant public preSaleBonus1Percent = 25;
    uint constant public preSaleBonus2Time = 1536019200; 
    uint constant public preSaleBonus2Percent = 15;
    uint constant public preSaleBonus3Time = 1536883200; 
    uint constant public preSaleBonus3Percent = 5;
    uint constant public preSaleBonus1Amount = 155   * 1e15;
    uint constant public preSaleBonus2Amount = 387   * 1e15;
    uint constant public preSaleBonus3Amount = 1550  * 1e15;
    uint constant public preSaleBonus4Amount = 15500 * 1e15;
    address constant public w_futureDevelopment = 0x4b297AB09bF4d2d8107fAa03cFF5377638Ec6C83;
    address constant public w_Reserv = 0xbb67c6E089c7801ab3c7790158868970ea0d8a7C;
    address constant public w_Founders = 0xa3b331037e29540F8BD30f3DE4fF4045a8115ff4;
    address constant public w_Team = 0xa8324689c94eC3cbE9413C61b00E86A96978b4A7;
    address constant public w_Advisers = 0x2516998954440b027171Ecb955A4C01DfF610F2d;
    address constant public w_Bounty = 0x1792b603F233220e1E623a6ab3FEc68deFa15f2F;
    event AddBonus(address indexed addr, uint256 amountWei, uint256 date, uint bonusType);
    struct Bonus {
        address addr;
        uint256 amountWei;
        uint256 date;
        uint bonusType;
    }
    struct Bonuses {
        address addr;
        uint256 numBonusesInAddress;
        uint256[] indexes;
    }
    mapping(address => Bonuses) public bonuses;
    Bonus[] public bonusList;
    function numBonuses() public view returns (uint256)
    { return bonusList.length; }
    function getBonusByAddressAndIndex(address _addr, uint256 _index) public view returns (uint256)
    { return bonuses[_addr].indexes[_index]; }
    constructor(
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _minimumGoal,
        uint256 _cap
    )
    Crowdsale(_rate * 1 ether, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    CappedCrowdsale(_cap * 1 ether)
    public
    {
        require(_rate > 0);
        require(_wallet != address(0));
        rate = _rate;
        wallet = _wallet;
        minimumGoal = _minimumGoal * 1 ether;
    }
    function changeTokenOwner(address _newTokenOwner) external onlyOwner {
        require(_newTokenOwner != 0x0);
        require(hasClosed());
        SafeGuardsToken(token).transferOwnership(_newTokenOwner);
    }
    function finalization() internal {
        require(isMinimumGoalReached());
        SafeGuardsToken(token).mint(w_futureDevelopment, tokensSold.mul(20).div(43));
        SafeGuardsToken(token).mint(w_Reserv, tokensSold.mul(20).div(43));
        SafeGuardsToken(token).mint(w_Founders, tokensSold.mul(7).div(43));
        SafeGuardsToken(token).mint(w_Team, tokensSold.mul(5).div(43));
        SafeGuardsToken(token).mint(w_Advisers, tokensSold.mul(3).div(43));
        SafeGuardsToken(token).mint(w_Bounty, tokensSold.mul(2).div(43));
        super.finalization();
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_weiAmount >= minimumAmountWei);
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        require(SafeGuardsToken(token).mintFrozen(_beneficiary, _tokenAmount));
        tokensSold = tokensSold.add(_tokenAmount);
    }
    function changeTransfersPaused(uint256 _newFrozenPauseTime) onlyOwner public returns (bool) {
        require(_newFrozenPauseTime > now);
        presaleTransfersPaused = _newFrozenPauseTime;
        SafeGuardsToken(token).changeFrozenTime(_newFrozenPauseTime);
        return true;
    }
    function changeBurnPaused(uint256 _newBurnPauseTime) onlyOwner public returns (bool) {
        require(_newBurnPauseTime > presaleBurnPaused);
        presaleBurnPaused = _newBurnPauseTime;
        SafeGuardsToken(token).changeBurnPausedTime(_newBurnPauseTime);
        return true;
    }
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        require(_weiAmount >= minimumAmountWei);
        boughtAmountOf[msg.sender] = boughtAmountOf[msg.sender].add(_weiAmount);
        if (_weiAmount >= preSaleBonus1Amount) {
            if (_weiAmount >= preSaleBonus2Amount) {
                if (_weiAmount >= preSaleBonus3Amount) {
                    if (_weiAmount >= preSaleBonus4Amount) {
                        addBonusToUser(msg.sender, _weiAmount, preSaleBonus4Amount, 4);
                    } else {
                        addBonusToUser(msg.sender, _weiAmount, preSaleBonus3Amount, 3);
                    }
                } else {
                    addBonusToUser(msg.sender, _weiAmount, preSaleBonus2Amount, 2);
                }
            } else {
                addBonusToUser(msg.sender, _weiAmount, preSaleBonus1Amount, 1);
            }
        }
    }
    function addBonusToUser(address _addr, uint256 _weiAmount, uint256 _bonusAmount, uint _bonusType) internal {
        uint256 countBonuses = _weiAmount.div(_bonusAmount);
        Bonus memory b;
        b.addr = _addr;
        b.amountWei = _weiAmount;
        b.date = now;
        b.bonusType = _bonusType;
        for (uint256 i = 0; i < countBonuses; i++) {
            bonuses[_addr].addr = _addr;
            bonuses[_addr].numBonusesInAddress++;
            bonuses[_addr].indexes.push(bonusList.push(b) - 1);
            emit AddBonus(_addr, _weiAmount, now, _bonusType);
        }
    }
    function getCurrentRate() public view returns (uint256) {
        if (now > preSaleBonus3Time) {
            return rate;
        }
        if (now < preSaleBonus1Time) {
            return rate.add(rate.mul(preSaleBonus1Percent).div(100));
        }
        if (now < preSaleBonus2Time) {
            return rate.add(rate.mul(preSaleBonus2Percent).div(100));
        }
        if (now < preSaleBonus3Time) {
            return rate.add(rate.mul(preSaleBonus3Percent).div(100));
        }
        return rate;
    }
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(_weiAmount);
    }
    event Refund(address buyer, uint weiAmount);
    event RefundLoaded(uint amount);
    function isMinimumGoalReached() public constant returns (bool) {
        return weiRaised >= minimumGoal;
    }
    function loadRefund() external payable {
        require(msg.sender == wallet);
        require(msg.value > 0);
        require(!isMinimumGoalReached());
        loadedRefund = loadedRefund.add(msg.value);
        emit RefundLoaded(msg.value);
    }
    function refund() external {
        require(!isMinimumGoalReached() && loadedRefund > 0);
        uint weiValue = boughtAmountOf[msg.sender];
        require(weiValue > 0);
        require(weiValue <= loadedRefund);
        boughtAmountOf[msg.sender] = 0;
        weiRefunded = weiRefunded.add(weiValue);
        msg.sender.transfer(weiValue);
        emit Refund(msg.sender, weiValue);
    }
}
