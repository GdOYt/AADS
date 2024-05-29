contract GlobalGoldCashToken is owned, TokenERC20 {
    uint256 public decimals = 18;
    string  public tokenName;
    string  public tokenSymbol;
    uint minBalanceForAccounts ;                                         
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    constructor() public {
        owner = msg.sender;
        totalSupply = 1000000000000000000;
        balanceOf[owner]=totalSupply;
        tokenName="Global Gold Cash";
        tokenSymbol="GGC";
    }
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
    }
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
}
