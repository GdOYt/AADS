contract GigaGivingToken is StandardToken {
    using SafeMath for uint256;
    uint256 private fundingGoal = 0 ether;
    uint256 private amountRaised;
    uint256 private constant PHASE_1_PRICE = 1600000000000000;
    uint256 private constant PHASE_2_PRICE = 2000000000000000; 
    uint256 private constant PHASE_3_PRICE = 2500000000000000; 
    uint256 private constant PHASE_4_PRICE = 4000000000000000;
    uint256 private constant PHASE_5_PRICE = 5000000000000000; 
    uint256 private constant DURATION = 5 weeks;  
    uint256 public constant TOTAL_TOKENS = 15000000;
    uint256 public constant  CROWDSALE_TOKENS = 12000000;  
    uint256 public startTime;
    uint256 public tokenSupply;
    address public creator;
    address public beneficiary;
    string public name = "Giga Coin";
    string public symbol = "GC";
    string public version = "GC.7";
    uint256 public decimals = 0;  
    mapping(address => uint256) public ethBalanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;   
    bool public refundsOpen = false;   
    function GigaGivingToken (address icoBeneficiary) public {
        creator = msg.sender;
        beneficiary = icoBeneficiary;
        totalSupply = TOTAL_TOKENS;         
        balances[beneficiary] = TOTAL_TOKENS.sub(CROWDSALE_TOKENS);
        Transfer(0x0, icoBeneficiary, TOTAL_TOKENS.sub(CROWDSALE_TOKENS));
        balances[this] = CROWDSALE_TOKENS;
        Transfer(0x0, this, CROWDSALE_TOKENS);              
        tokenSupply = CROWDSALE_TOKENS;
        startTime = 1510765200;
    }   
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
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
        ethBalanceOf[msg.sender] = ethBalanceOf[msg.sender].add(amount);              
        balances[msg.sender] = balances[msg.sender].add(coinTotal);
        balances[this] = balances[this].sub(coinTotal);
        amountRaised = amountRaised.add(amount);
        tokenSupply = tokenSupply.sub(coinTotal);
        transfer(msg.sender, coinTotal);
    }  
    modifier afterDeadline() { 
        if (now >= (startTime + DURATION)) {
            _;
        }
    }
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
        }
        crowdsaleClosed = true;
    }
    function safeWithdrawal() public afterDeadline {
        if (refundsOpen) {
            uint amount = ethBalanceOf[msg.sender];
            ethBalanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (!msg.sender.send(amount)) {
                    ethBalanceOf[msg.sender] = amount;
                }
            }
        }
        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                this.transfer(msg.sender, tokenSupply);
            } else {               
                fundingGoalReached = false;
            }
        }
    }
    function enableRefunds() public afterDeadline {
        require(msg.sender == beneficiary);
        refundsOpen = true;
    }
}
