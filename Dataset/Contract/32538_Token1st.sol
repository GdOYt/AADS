contract Token1st {
  address public currentTradingSystem;
  address public currentExchangeSystem;
  mapping(address => uint) public balanceOf;
  mapping(address => mapping (address => uint)) public allowance;
  mapping(address => mapping (address => uint)) public tradingBalanceOf;
  mapping(address => mapping (address => uint)) public exchangeBalanceOf;
  function getBalanceOf(address _address) view public returns (uint amount){
    return balanceOf[_address];
  }
  event Transfer (address _to, address _from, uint _decimalAmount);
  function transferDecimalAmountFrom(address _from, address _to, uint _value) public returns (bool success) {
    require(balanceOf[_from]
      - tradingBalanceOf[_from][currentTradingSystem]
      - exchangeBalanceOf[_from][currentExchangeSystem] >= _value);                  
    require(balanceOf[_to] + (_value) >= balanceOf[_to]);   
    require(_value <= allowance[_from][msg.sender]);    
    balanceOf[_from] -= _value;                           
    balanceOf[_to] += _value;                             
    allowance[_from][msg.sender] -= _value;
    Transfer(_to, _from, _value);
    return true;
  }
  function approveSpenderDecimalAmount(address _spender, uint _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    return true;
  }
}
