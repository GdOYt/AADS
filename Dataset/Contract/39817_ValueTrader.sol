contract ValueTrader is SafeMath,ValueToken{
    function () payable {
    }
    struct TokenData {
        bool isValid;  
        uint256 basePrice;  
        uint256 baseLiquidity;  
        uint256 priceScaleFactor;  
        bool hasDividend;
        address divContractAddress;
        bytes divData;
    }
    address owner;
    address etherContract;
    uint256 tradeCoefficient;  
    mapping (address => TokenData) tokenManage;
    bool public burning = false;  
    bool public draining = false;  
    modifier owned(){
        assert(msg.sender == owner);
        _;
    }
    modifier burnBlock(){
        assert(!burning);
        _;
    }
    modifier drainBlock(){
        assert(!draining);
        _;
    }
    function toggleDrain() burnBlock owned {
        draining = !draining;
    }
    function toggleBurn() owned {
        assert(draining);
        assert(balanceOf(owner) == supplyNow);
        burning = !burning;
    }
    function die() owned burnBlock{
        selfdestruct(owner);
    }
    function validateToken(address token_, uint256 bP_, uint256 bL_, uint256 pF_) owned {
        tokenManage[token_].isValid = true;
        tokenManage[token_].basePrice = bP_;
        tokenManage[token_].baseLiquidity = bL_;
        tokenManage[token_].priceScaleFactor = pF_;
    }
    function configureTokenDividend(address token_, bool hD_, address dA_, bytes dD_) owned {
        tokenManage[token_].hasDividend = hD_;
        tokenManage[token_].divContractAddress = dA_;
        tokenManage[token_].divData = dD_;
    }
    function callDividend(address token_) owned {
        assert(tokenManage[token_].hasDividend);
        assert(tokenManage[token_].divContractAddress.call.value(0)(tokenManage[token_].divData));
    }
    function invalidateToken(address token_) owned {
        tokenManage[token_].isValid = false;
    }
    function changeOwner(address owner_) owned {
        owner = owner_;
    }
    function changeFee(uint256 tradeFee) owned {
        tradeCoefficient = tradeFee;
    }
    function changeEtherContract(address eC) owned {
        etherContract = eC;
    }
    event Buy(address tokenAddress, address buyer, uint256 amount, uint256 remaining);
    event Sell(address tokenAddress, address buyer, uint256 amount, uint256 remaining);
    event Trade(address fromTokAddress, address toTokAddress, address buyer, uint256 amount);
    function ValueTrader(){
        owner = msg.sender;
        burning = false;
        draining = false;
    }
    function valueWithFee(uint256 tempValue) internal returns (uint256 doneValue){
        doneValue = safeMul(tempValue,tradeCoefficient)/10000;
        if(tradeCoefficient < 10000){
            createValue(owner,safeSub(tempValue,doneValue));
        }
    }
    function currentPrice(address token) constant returns (uint256 price){
        if(draining){
            price = 1;
        } else {
        assert(tokenManage[token].isValid);
        uint256 basePrice = tokenManage[token].basePrice;
        uint256 baseLiquidity = tokenManage[token].baseLiquidity;
        uint256 priceScaleFactor = tokenManage[token].priceScaleFactor;
        uint256 currentLiquidity;
        if(token == etherContract){
            currentLiquidity = this.balance;
        }else{
            currentLiquidity = Token(token).balanceOf(this);
        }
        price = safeAdd(basePrice,safeMul(priceScaleFactor,baseLiquidity/currentLiquidity));
        }
    }
    function currentLiquidity(address token) constant returns (uint256 liquidity){
        liquidity = Token(token).balanceOf(this);
    }
    function valueToToken(address token, uint256 amount) constant internal returns (uint256 value){
        value = amount/currentPrice(token);
        assert(value != 0);
    }
    function tokenToValue(address token, uint256 amount) constant internal returns (uint256 value){
        value = safeMul(amount,currentPrice(token));
    }
    function sellToken(address token, uint256 amount) drainBlock {
        assert(verifiedTransferFrom(token,msg.sender,amount));
        assert(createValue(msg.sender, tokenToValue(token,amount)));
        Sell(token, msg.sender, amount, balances[msg.sender]);
    }
    function buyToken(address token, uint256 amount) {
        assert(!(valueToToken(token,balances[msg.sender]) < amount));
        assert(destroyValue(msg.sender, tokenToValue(token,amount)));
        assert(Token(token).transfer(msg.sender, amount));
        Buy(token, msg.sender, amount, balances[msg.sender]);
    }
    function sellEther() payable drainBlock {
        assert(createValue(msg.sender, tokenToValue(etherContract,msg.value)));
        Sell(etherContract, msg.sender, msg.value, balances[msg.sender]);
    }
    function buyEther(uint256 amount) {
        assert(valueToToken(etherContract,balances[msg.sender]) >= amount);
        assert(destroyValue(msg.sender, tokenToValue(etherContract,amount)));
        assert(msg.sender.call.value(amount)());
        Buy(etherContract, msg.sender, amount, balances[msg.sender]);
    }
    function quickTrade(address tokenFrom, address tokenTo, uint256 input) payable drainBlock {
        uint256 inValue;
        uint256 tempInValue = safeAdd(tokenToValue(etherContract,msg.value),
        tokenToValue(tokenFrom,input));
        inValue = valueWithFee(tempInValue);
        uint256 outValue = valueToToken(tokenTo,inValue);
        assert(verifiedTransferFrom(tokenFrom,msg.sender,input));
        if (tokenTo == etherContract){
          assert(msg.sender.call.value(outValue)());  
        } else assert(Token(tokenTo).transfer(msg.sender, outValue));
        Trade(tokenFrom, tokenTo, msg.sender, inValue);
    }
    function verifiedTransferFrom(address tokenFrom, address senderAdd, uint256 amount) internal returns (bool success){
    uint256 balanceBefore = Token(tokenFrom).balanceOf(this);
    success = Token(tokenFrom).transferFrom(senderAdd, this, amount);
    uint256 balanceAfter = Token(tokenFrom).balanceOf(this);
    assert((safeSub(balanceAfter,balanceBefore)==amount));
    }
}
