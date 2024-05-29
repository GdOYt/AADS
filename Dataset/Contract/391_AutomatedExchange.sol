contract AutomatedExchange is ApproveAndCallFallBack{
    uint256 PSN=100000000000000;
    uint256 PSNH=50000000000000;
    address vrfAddress=0x9E129e47213589C5Da4d92CC6Bb056425d60b0e1;  
    VerifyToken vrfcontract=VerifyToken(vrfAddress);
    event BoughtToken(uint tokens,uint eth,address indexed to);
    event SoldToken(uint tokens,uint eth,address indexed to);
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public{
        require(vrfcontract.activated());
        require(msg.sender==vrfAddress);
        uint256 tokenValue=calculateTokenSell(tokens);
        vrfcontract.transferFrom(from,this,tokens);
        from.transfer(tokenValue);
        emit SoldToken(tokens,tokenValue,from);
    }
    function buyTokens() public payable{
        require(vrfcontract.activated());
        uint256 tokensBought=calculateTokenBuy(msg.value,SafeMath.sub(this.balance,msg.value));
        vrfcontract.transfer(msg.sender,tokensBought);
        emit BoughtToken(tokensBought,msg.value,msg.sender);
    }
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateTokenSell(uint256 tokens) public view returns(uint256){
        return calculateTrade(tokens,vrfcontract.balanceOf(this),this.balance);
    }
    function calculateTokenBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,vrfcontract.balanceOf(this));
    }
    function calculateTokenBuySimple(uint256 eth) public view returns(uint256){
        return calculateTokenBuy(eth,this.balance);
    }
    function () public payable {}
    function getBalance() public view returns(uint256){
        return this.balance;
    }
    function getTokenBalance() public view returns(uint256){
        return vrfcontract.balanceOf(this);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
