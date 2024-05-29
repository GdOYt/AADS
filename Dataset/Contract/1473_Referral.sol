contract Referral is Declaration, Ownable {
    using SafeMath for uint;
    WealthBuilderToken private token;
    Data private data;
    Investors private investors;
    uint public investorsBalance;
    uint public ethUsdRate;
    function Referral(uint _ethUsdRate, address _token, address _data, address _investors) public {
        ethUsdRate = _ethUsdRate;
        token = WealthBuilderToken(_token);
        data = Data(_data);
        investors = Investors(_investors);
        investorsBalance = 0;
    }
    function() payable public {
    }
    function invest(address client, uint8 depositsCount) payable public {
        uint amount = msg.value;
        if (depositsCount < 5) {
            uint serviceFee;
            uint investorsFee = 0;
            if (depositsCount == 0) {
                uint8 investorsFeePercentage = investors.getInvestorsFee();
                serviceFee = amount * (serviceFees[depositsCount].sub(investorsFeePercentage));
                investorsFee = amount * investorsFeePercentage;
                investorsBalance += investorsFee;
            } else {
                serviceFee = amount * serviceFees[depositsCount];
            }
            uint referralFee = amount * referralFees[depositsCount];
            distribute(data.parentOf(client), 0, depositsCount, amount);
            uint active = (amount * 100)
            .sub(referralFee)
            .sub(serviceFee)
            .sub(investorsFee);
            token.mint(client, active / 100 * token.rate() / token.mrate());
            data.addBalance(owner, serviceFee * 10000);
        } else {
            token.mint(client, amount * token.rate() / token.mrate());
        }
    }
    function distribute(
        address _node,
        uint _prevPercentage,
        uint8 _depositsCount,
        uint _amount
    )
    private
    {
        address node = _node;
        uint prevPercentage = _prevPercentage;
        while(node != address(0)) {
            uint8 status = data.statuses(node);
            uint nodePercentage = feeDistribution[status][_depositsCount];
            uint percentage = nodePercentage.sub(prevPercentage);
            data.addBalance(node, _amount * percentage * 10000);
            data.addReferralDeposit(node, _amount * ethUsdRate / 10**18);
            updateStatus(node, status);
            node = data.parentOf(node);
            prevPercentage = nodePercentage;
        }
    }
    function updateStatus(address _node, uint8 _status) private {
        uint refDep = data.referralDeposits(_node);
        for (uint i = thresholds.length - 1; i > _status; i--) {
            uint threshold = thresholds[i] * 100;
            if (refDep >= threshold) {
                data.setStatus(_node, statusThreshold[threshold]);
                break;
            }
        }
    }
    function distributeInvestorsFee(uint start, uint end) onlyOwner public {
        for (uint i = start; i < end; i++) {
            address investor = investors.investors(i);
            uint investorPercentage = investors.investorPercentages(investor);
            data.addInvestorBalance(investor, investorsBalance * investorPercentage);
        }
        if (end == investors.getInvestorsCount()) {
            investorsBalance = 0;
        }
    }
    function setRate(uint _rate) onlyOwner public {
        token.setRate(_rate);
    }
    function setEthUsdRate(uint _ethUsdRate) onlyOwner public {
        ethUsdRate = _ethUsdRate;
    }
    function invite(
        address _inviter,
        address _invitee
    )
    public onlyOwner
    {
        data.setParent(_invitee, _inviter);
        data.setStatus(_invitee, 0);
    }
    function setStatus(address _addr, uint8 _status) public onlyOwner {
        data.setStatus(_addr, _status);
    }
    function setInvestors(address _addr) public onlyOwner {
        investors = Investors(_addr);
    }
    function withdraw(address _addr, uint256 _amount, bool investor) public onlyOwner {
        uint amount = investor ? data.investorBalanceOf(_addr)
        : data.balanceOf(_addr);
        require(amount >= _amount && this.balance >= _amount);
        if (investor) {
            data.subtrInvestorBalance(_addr, _amount * 1000000);
        } else {
            data.subtrBalance(_addr, _amount * 1000000);
        }
        _addr.transfer(_amount);
    }
    function withdrawOwner(address _addr, uint256 _amount) public onlyOwner {
        require(this.balance >= _amount);
        _addr.transfer(_amount);
    }
    function withdrawToken(address _addr, uint256 _amount) onlyOwner public {
        token.burn(_addr, _amount);
        uint256 etherValue = _amount * token.mrate() / token.rate();
        _addr.transfer(etherValue);
    }
    function transferTokenOwnership(address _addr) onlyOwner public {
        token.transferOwnership(_addr);
    }
    function transferDataOwnership(address _addr) onlyOwner public {
        data.transferOwnership(_addr);
    }
}
