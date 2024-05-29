contract GigaGivingICO {
    using SafeMath for uint256;
    uint256 private fundingGoal;
    uint256 private amountRaised;
    uint256 public constant PHASE_1_PRICE = 1600000000000000;
    uint256 public constant PHASE_2_PRICE = 2000000000000000; 
    uint256 public constant PHASE_3_PRICE = 2500000000000000; 
    uint256 public constant PHASE_4_PRICE = 4000000000000000;
    uint256 public constant PHASE_5_PRICE = 5000000000000000; 
    uint256 public constant DURATION = 5 weeks;  
    uint256 public startTime;
    uint256 public tokenSupply;
    address public beneficiary;
    GigaGivingToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;
    event GoalReached(address goalBeneficiary, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);
    function GigaGivingICO (address icoToken, address icoBeneficiary) public {
        fundingGoal = 1000 ether; 
        startTime = 1510765200;
        beneficiary = icoBeneficiary;
        tokenReward = GigaGivingToken(icoToken);
        tokenSupply = 12000000;
    }
    function () public payable {
        require(now >= startTime);
        require(now <= startTime + DURATION);
        require(!crowdsaleClosed);
        require(msg.value > 0);
        uint256 amount = msg.value;
        uint256 coinTotal = 0;      
        if (now > startTime + 4 weeks) {
            coinTotal = amount.div(PHASE_5_PRICE);
        } else if (now > startTime + 3 weeks) {
            coinTotal = amount.div(PHASE_4_PRICE);
        } else if (now > startTime + 2 weeks) {
            coinTotal = amount.div(PHASE_3_PRICE);
        } else if (now > startTime + 1 weeks) {
            coinTotal = amount.div(PHASE_2_PRICE);
        } else {
            coinTotal = amount.div(PHASE_1_PRICE);
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        tokenSupply = tokenSupply.sub(coinTotal);
        tokenReward.transfer(msg.sender, coinTotal);
        FundTransfer(msg.sender, amount, true);
    }  
    modifier afterDeadline() { 
        if (now >= (startTime + DURATION)) {
            _;
        }
    }
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }
    function safeWithdrawal() public afterDeadline {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                tokenReward.transfer(msg.sender, tokenSupply);
                FundTransfer(beneficiary, amountRaised, false);                
            } else {               
                fundingGoalReached = false;
            }
        }
    }
}
