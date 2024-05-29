contract OMTM is StandardToken, BurnableToken, Ownable {
    string  public constant name = "One Metric That Matters";
    string  public constant symbol = "OMTM";
    uint8   public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY      = 500000000  * (10 ** uint256(decimals));
    uint256 public constant FREE_SUPPLY         = 350000000  * (10 ** uint256(decimals));
    uint256 constant nextFreeCount = 3500 * (10 ** uint256(decimals)) ;
    mapping(address => bool) touched;
    uint256 startTime;
    uint256 constant MONTH = 30 days;
    constructor() public {
      startTime = now;
      totalSupply_ = INITIAL_SUPPLY;
      balances[address(this)] = FREE_SUPPLY;
      emit Transfer(0x0, address(this), FREE_SUPPLY);
      balances[msg.sender] = INITIAL_SUPPLY - FREE_SUPPLY;
      emit Transfer(0x0, msg.sender, INITIAL_SUPPLY - FREE_SUPPLY);
    }
    function _transfer(address _from, address _to, uint _value) internal {     
        require (balances[_from] >= _value);                
        require (balances[_to] + _value > balances[_to]);  
        balances[_from] = balances[_from].sub(_value);                          
        balances[_to] = balances[_to].add(_value);                             
        emit Transfer(_from, _to, _value);
    }
    function () external payable {
        if (!touched[msg.sender] ) {
          touched[msg.sender] = true;
          _transfer(address(this), msg.sender, nextFreeCount ); 
        }
        _burn();
    }
    function _burn() internal {
        if (now - startTime > MONTH && balances[address(this)] > 0) {
            totalSupply_ = totalSupply_.sub(balances[address(this)]);
            balances[address(this)] = 0;
        }
    }
    function safeWithdrawal() onlyOwner public {
        owner.transfer(address(this).balance);
    }
}
