contract MyAdvancedToken is owned, TokenERC20 {
    uint256 public sellPrice;
    uint256 public buyPrice;
    mapping (address => bool) public frozenAccount;
    mapping(address => uint[]) public frozenAccountCoinList;
    event FrozenFunds(address target, bool frozen);
    event FrozenCoinsByTime(address target, uint256 coinNum, uint256 timestamp);
    function MyAdvancedToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                                
        require (balanceOf[_from] >= _value);                
        require (balanceOf[_to] + _value > balanceOf[_to]);  
        require(!frozenAccount[_from]);                      
        require(!frozenAccount[_to]);                        
        uint frozenAccountCoin = _calFrozenAccountCoin(_from);
        require(frozenAccountCoin == 0 || (balanceOf[_from] - _value) >= frozenAccountCoin);
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
    function frozenAccountCoinByTime(address target, uint timestamp, uint256 num) onlyOwner public{
        frozenAccountCoinList[target].push(timestamp);
        frozenAccountCoinList[target].push(num);
        FrozenCoinsByTime(target, num, timestamp);
    }
    function frozenAccountCoinByHour(address target, uint hourCount, uint256 num) onlyOwner public{
        uint timestamp = now + hourCount * 3600;
        frozenAccountCoinList[target].push(timestamp);
        frozenAccountCoinList[target].push(num);
        FrozenCoinsByTime(target, num, timestamp);
    }
    function _calFrozenAccountCoin(address target) public returns(uint num){
        for(uint i = 0; i < frozenAccountCoinList[target].length; i++) {
            if (now <= frozenAccountCoinList[target][i]){
                i = i + 1;
                num = num + frozenAccountCoinList[target][i];
            }else{
                i = i + 1;
            }
        }
        return num;
    }
    function getFrozenAccountCoinCount(address target) onlyOwner view public returns(uint num){
        num = _calFrozenAccountCoin(target);
        return num;
    }
    function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool success) {
        _transfer(_from, _to, _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[_from] >= _value);                 
        balanceOf[_from] -= _value;                          
        totalSupply -= _value;                               
        Burn(_from, _value);
        return true;
    }
}
