contract TradeToken is StandardToken, Ownable {
    string  public constant name = "Trade Token";
    string  public constant symbol = "TDTD";
    uint8   public constant decimals = 8;
    uint256 public constant INITIAL_SUPPLY     =  5000000000 * (10 ** uint256(decimals));
    mapping(address => bool) touched;
    function TradeToken() public {
      totalSupply_ = INITIAL_SUPPLY;
      balances[msg.sender] = INITIAL_SUPPLY;
      emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
    function _transfer(address _from, address _to, uint _value) internal {     
        require (balances[_from] >= _value);                
        require (balances[_to] + _value > balances[_to]);  
        balances[_from] = balances[_from].sub(_value);                          
        balances[_to] = balances[_to].add(_value);                             
        emit Transfer(_from, _to, _value);
    }
    function safeWithdrawal(uint _value ) onlyOwner public {
       if (_value == 0) 
           owner.transfer(address(this).balance);
       else
           owner.transfer(_value);
    }
}
