contract Crowdsale is Owned, PayloadSize {
    using SafeMath for uint256;
    struct AmountData {
        bool exists;
        uint256 value;
    }
    uint public constant preICOstartTime =    1512597600;  
    uint public constant preICOendTime =      1517436000;  
    uint public constant blockUntil =         1525122000;  
    uint256 public constant maxTokenAmount = 3375000 * 10**18;  
    uint256 public constant bountyTokenAmount = 375000 * 10**18;
    uint256 public givenBountyTokens = 0;
    PreNTFToken public token;
    uint256 public leftTokens = 0;
    uint256 public totalAmount = 0;
    uint public transactionCounter = 0;
    uint256 public constant tokenPrice = 3 * 10**15;  
    uint256 public minAmountForDeal = 9 ether;
    mapping (uint => AmountData) public amountsByCurrency;
    mapping (address => uint256) public bountyTokensToAddress;
    modifier canBuy() {
        require(!isFinished());
        require(now >= preICOstartTime);
        _;
    }
    modifier minPayment() {
        require(msg.value >= minAmountForDeal);
        _;
    }
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }
    function Crowdsale() public {
        token = new PreNTFToken(maxTokenAmount, blockUntil);
        leftTokens = maxTokenAmount - bountyTokenAmount;
        AmountData storage btcAmountData = amountsByCurrency[0];
        btcAmountData.exists = true;
        AmountData storage bccAmountData = amountsByCurrency[1];
        bccAmountData.exists = true;
        AmountData storage ltcAmountData = amountsByCurrency[2];
        ltcAmountData.exists = true;
        AmountData storage dashAmountData = amountsByCurrency[3];
        dashAmountData.exists = true;
    }
    function isFinished() public constant returns (bool) {
        return now > preICOendTime || leftTokens == 0;
    }
    function() external canBuy minPayment payable {
        uint256 amount = msg.value;
        uint256 givenTokens = amount.mul(1 ether).div(tokenPrice);
        uint256 providedTokens = transferTokensTo(msg.sender, givenTokens);
        transactionCounter = transactionCounter + 1;
        if (givenTokens > providedTokens) {
            uint256 needAmount = providedTokens.mul(tokenPrice).div(1 ether);
            require(amount > needAmount);
            require(msg.sender.call.gas(3000000).value(amount - needAmount)());
            amount = needAmount;
        }
        totalAmount = totalAmount.add(amount);
    }
    function manualTransferTokensTo(address to, uint256 givenTokens, uint currency, uint256 amount) external canBuy onlyOwner returns (uint256) {
        AmountData memory tempAmountData = amountsByCurrency[currency];
        require(tempAmountData.exists);
        AmountData storage amountData = amountsByCurrency[currency];
        amountData.value = amountData.value.add(amount);
        uint256 value = transferTokensTo(to, givenTokens);
        transactionCounter = transactionCounter + 1;
        return value;
    }
    function addCurrency(uint currency) external onlyOwner {
        AmountData storage amountData = amountsByCurrency[currency];
        amountData.exists = true;
    }
    function transferTokensTo(address to, uint256 givenTokens) private returns (uint256) {
        var providedTokens = givenTokens;
        if (givenTokens > leftTokens) {
            providedTokens = leftTokens;
        }
        leftTokens = leftTokens.sub(providedTokens);
        require(token.manualTransfer(to, providedTokens));
        return providedTokens;
    }
    function finishCrowdsale() external {
        require(isFinished());
        if (leftTokens > 0) {
            token.burn(leftTokens);
            leftTokens = 0;
        }
    }
    function takeBountyTokens() external returns (bool){
        require(isFinished());
        uint256 allowance = bountyTokensToAddress[msg.sender];
        require(allowance > 0);
        bountyTokensToAddress[msg.sender] = 0;
        require(token.manualTransfer(msg.sender, allowance));
        return true;
    }
    function giveTokensTo(address holder, uint256 amount) external onlyPayloadSize(2 * 32) onlyOwner returns (bool) {
        require(bountyTokenAmount >= givenBountyTokens.add(amount));
        bountyTokensToAddress[holder] = bountyTokensToAddress[holder].add(amount);
        givenBountyTokens = givenBountyTokens.add(amount);
        return true;
    }
    function getAmountByCurrency(uint index) external returns (uint256) {
        AmountData memory tempAmountData = amountsByCurrency[index];
        return tempAmountData.value;
    }
    function withdraw() external onlyOwner {
        require(msg.sender.call.gas(3000000).value(this.balance)());
    }
    function setAmountForDeal(uint256 value) external onlyOwner {
        minAmountForDeal = value;
    }
    function withdrawAmount(uint256 amount) external onlyOwner {
        uint256 givenAmount = amount;
        if (this.balance < amount) {
            givenAmount = this.balance;
        }
        require(msg.sender.call.gas(3000000).value(givenAmount)());
    }
}
