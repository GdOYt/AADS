contract ShopKeeper is SafeMath{
    ValueTrader public shop;
    address holderA;  
    address holderB;  
    modifier onlyHolders(){
        assert(msg.sender == holderA || msg.sender == holderB);
        _;
    }
    modifier onlyA(){
        assert(msg.sender == holderA);
        _;
    }
    function(){
        throw;
    }
    function ShopKeeper(address other){
        shop = new ValueTrader();
        holderA = msg.sender;
        holderB = other;
    }
    function giveAwayOwnership(address newHolder) onlyHolders {
        if(msg.sender == holderB){
            holderB = newHolder;
        } else {
            holderA = newHolder;
        }
    }
    function splitProfits(){
        uint256 unprocessedProfit = shop.balanceOf(this);
        uint256 equalShare = unprocessedProfit/2;
        assert(shop.transfer(holderA,equalShare));
        assert(shop.transfer(holderB,equalShare));
    }
    function toggleDrain() onlyA {
        shop.toggleDrain();
    }
    function toggleBurn() onlyA {
        shop.toggleBurn();
    }
    function die() onlyA {
        shop.die();
    }
    function validateToken(address token_, uint256 bP_, uint256 bL_, uint256 pF_) onlyHolders {
        shop.validateToken(token_,bP_,bL_,pF_);
    }
    function configureTokenDividend(address token_, bool hD_, address dA_, bytes dD_) onlyA {
        shop.configureTokenDividend(token_,hD_,dA_,dD_);
    }
    function callDividend(address token_) onlyA {
        shop.callDividend(token_);
    }
    function invalidateToken(address token_) onlyHolders {
        shop.invalidateToken(token_);
    }
    function changeOwner(address owner_) onlyA {
        if(holderB == holderA){ 
            shop.changeOwner(owner_); 
        }
        holderA = owner_;
    }
    function changeShop(address newShop) onlyA {
        if(holderB == holderA){
            shop = ValueTrader(newShop);
        }
    }
    function changeFee(uint256 tradeFee) onlyHolders {
        shop.changeFee(tradeFee);
    }
    function changeEtherContract(address eC) onlyHolders {
        shop.changeEtherContract(eC);
    }
}
