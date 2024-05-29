contract KYROInv is StandardToken {
    string public constant name = "KYRO Inv";
    string public constant symbol = "KR";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 3 * 10**9 * (10**uint256(decimals));
    uint256 public weiRaised;
    uint256 public tokenAllocated;
    address public owner;
    bool public saleToken = true;
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    function KYROInv() public {
        totalSupply = INITIAL_SUPPLY;
        owner = msg.sender;
        balances[owner] = INITIAL_SUPPLY;
        tokenAllocated = 0;
        transfersEnabled = true;
    }
    function() payable public {
        buyTokens(msg.sender);
    }
    function buyTokens(address _investor) public payable returns (uint256){
        require(_investor != address(0));
        require(saleToken == true);
        address wallet = owner;
        uint256 weiAmount = msg.value;
        uint256 tokens = validPurchaseTokens(weiAmount);
        if (tokens == 0) {revert();}
        weiRaised = weiRaised.add(weiAmount);
        tokenAllocated = tokenAllocated.add(tokens);
        mint(_investor, tokens, owner);
        TokenPurchase(_investor, weiAmount, tokens);
        wallet.transfer(weiAmount);
        return tokens;
    }
    function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
        uint256 addTokens = getTotalAmountOfTokens(_weiAmount);
        if (addTokens > balances[owner]) {
            TokenLimitReached(tokenAllocated, addTokens);
            return 0;
        }
        return addTokens;
    }
    function getTotalAmountOfTokens(uint256 _weiAmount) internal pure returns (uint256) {
        uint256 amountOfTokens = 0;
        if(_weiAmount == 0){
            amountOfTokens = 250 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.001 ether){
            amountOfTokens = 3 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.002 ether){
            amountOfTokens = 6 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.003 ether){
            amountOfTokens = 9 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.004 ether){
            amountOfTokens = 12 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.005 ether){
            amountOfTokens = 15750 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.006 ether){
            amountOfTokens = 18900 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.007 ether){
            amountOfTokens = 22050 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.008 ether){
            amountOfTokens = 25200 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.009 ether){
            amountOfTokens = 28350 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.01 ether){
            amountOfTokens = 33 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.02 ether){
            amountOfTokens = 66 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.03 ether){
            amountOfTokens = 99 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.04 ether){
            amountOfTokens = 132 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.05 ether){
            amountOfTokens = 165 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.06 ether){
            amountOfTokens = 198 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.07 ether){
            amountOfTokens = 231 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.08 ether){
            amountOfTokens = 264 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.09 ether){
            amountOfTokens = 295 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.1 ether){
            amountOfTokens = 345 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.2 ether){
            amountOfTokens = 690 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.3 ether){
            amountOfTokens = 1035 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.4 ether){
            amountOfTokens = 1380 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.5 ether){
            amountOfTokens = 1725 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.6 ether){
            amountOfTokens = 2070 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.7 ether){
            amountOfTokens = 2415 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.8 ether){
            amountOfTokens = 2760 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.9 ether){
            amountOfTokens = 3450 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 1 ether){
            amountOfTokens = 3600 * 10**3 * (10**uint256(decimals));
        }
        return amountOfTokens;
    }
    function mint(address _to, uint256 _amount, address _owner) internal returns (bool) {
        require(_to != address(0));
        require(_amount <= balances[_owner]);
        balances[_to] = balances[_to].add(_amount);
        balances[_owner] = balances[_owner].sub(_amount);
        Transfer(_owner, _to, _amount);
        return true;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function changeOwner(address _newOwner) onlyOwner public returns (bool){
        require(_newOwner != address(0));
        OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
    function startSale() public onlyOwner {
        saleToken = true;
    }
    function stopSale() public onlyOwner {
        saleToken = false;
    }
    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }
    function claimTokens() public onlyOwner {
        owner.transfer(this.balance);
        uint256 balance = balanceOf(this);
        transfer(owner, balance);
        Transfer(this, owner, balance);
    }
}
