contract StandardToken is Token {
    using SafeMath for uint256;
    uint8 public decimals;                 
    mapping(address=>bool) internal withoutFee;
    uint256 internal maxFee;
    function transfer(address _to, uint256 _value) returns (bool success) {
        uint256 fee=getFee(_value);
        if (balances[msg.sender].add(fee) >= _value && _value > 0) {
            doTransfer(msg.sender,_to,_value,fee);
            return true;
        }  else { return false; }
    }
    function getFee(uint256 _value) private returns (uint256){
        uint256 onePercentOfValue=_value.onePercent();
        uint256 fee=uint256(maxFee).power(decimals);
        if (_value.add(onePercentOfValue) >= fee) {
            return fee;
        } if (_value.add(onePercentOfValue) < fee) {
            return onePercentOfValue;
        }
    }
    function doTransfer(address _from,address _to,uint256 _value,uint256 fee) internal {
            balances[_from] =balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            if(!withoutFee[_from]){
                doBurn(_from,fee);
            }
    }
    function doBurn(address _from,uint256 _value) private returns (bool success){
        require(balanceOf(_from) >= _value);    
        balances[_from] =balances[_from].sub(_value);             
        _totalSupply =_totalSupply.sub(_value);                       
        Burn(_from, _value);
        return true;
    }
    function burn(address _from,uint256 _value) public returns (bool success) {
        return doBurn(_from,_value);
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        uint256 fee=getFee(_value);  
        uint256 valueWithFee=_value;
        if(!withoutFee[_from]){
            valueWithFee=valueWithFee.add(fee);
        }
        if (balances[_from] >= valueWithFee && allowed[_from][msg.sender] >= valueWithFee && _value > 0 ) {
            doTransfer(_from,_to,_value,fee);
            allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(valueWithFee);
            return true;
        } else { return false; }
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    function totalSupply() constant returns (uint totalSupply){
        return _totalSupply;
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply;
}
