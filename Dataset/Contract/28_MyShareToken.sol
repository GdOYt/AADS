contract MyShareToken is owned, TokenSBT{
    uint256 public sellPrice;
    uint256 public buyPrice;
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    function MyShareToken() TokenSBT() public {}
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                                
        require (balanceOf[_from] >= _value);                
        require (balanceOf[_to] + _value > balanceOf[_to]);  
        require(!frozenAccount[_from]);                      
        require(!frozenAccount[_to]);                        
        balanceOf[_from] -= _value;                          
        balanceOf[_to] += _value;                            
        Transfer(_from, _to, _value);
    }
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    function buy() payable public {
        uint amount = msg.value / buyPrice;          
        _transfer(this, msg.sender, amount);
    }
    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice); 
        _transfer(msg.sender, this, amount);    
        msg.sender.transfer(amount * sellPrice); 
    }
}
