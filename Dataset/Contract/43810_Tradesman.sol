contract Tradesman is owned, TokenERC20 {
    uint256 public sellPrice;
    uint256 public sellMultiplier;   
    uint256 public buyPrice;
    uint256 public buyMultiplier;    
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    function Tradesman(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                                
        require (balanceOf[_from] >= _value);                                
        require (balanceOf[_to] + _value > balanceOf[_to]);                  
        require (!frozenAccount[_from]);                                     
        require (!frozenAccount[_to]);                                       
        balanceOf[_from] -= _value;                                          
        balanceOf[_to] += _value;                                            
        Transfer(_from, _to, _value);
    }
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    function setPrices(uint256 newSellPrice, uint256 newSellMultiplier, uint256 newBuyPrice, uint256 newBuyMultiplier) onlyOwner public {
        sellPrice       = newSellPrice;                                      
        sellMultiplier  = newSellMultiplier;                                 
        buyPrice        = newBuyPrice;                                       
        buyMultiplier   = newBuyMultiplier;                                  
    }
    function () payable public {
        uint amount = msg.value * buyMultiplier / buyPrice;                  
        _transfer(this, msg.sender, amount);                                 
    }
    function buy() payable public {
        require (buyMultiplier > 0);                                         
        uint amount = msg.value * buyMultiplier / buyPrice;                  
        _transfer(this, msg.sender, amount);                                 
    }
    function sell(uint256 amount) public {
        require (sellMultiplier > 0);                                        
        require(this.balance >= amount * sellPrice / sellMultiplier);        
        _transfer(msg.sender, this, amount);                                 
        msg.sender.transfer(amount * sellPrice / sellMultiplier);            
    }
    function etherTransfer(address _to, uint _value) onlyOwner public {
        _to.transfer(_value);
    }
    function genericTransfer(address _to, uint _value, bytes _data) onlyOwner public {
         require(_to.call.value(_value)(_data));
    }
    function tokenTransfer(address _to, uint _value) onlyOwner public {
         _transfer(this, _to, _value);                                
    }
}
