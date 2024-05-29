contract TongTong is Token, Owned {
    using SafeMath for uint256;
    uint public  _totalSupply;
    string public   name;         
    uint8 public constant decimals = 8;    
    string public  symbol;    
    uint256 public mintCount;
    uint256 public deleteToken;
    uint256 public soldToken;
    mapping (address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowed;
    function TongTong(string coinName,string coinSymbol,uint initialSupply) {
        _totalSupply = initialSupply *10**uint256(decimals);                        
        balanceOf[msg.sender] = _totalSupply; 
        name = coinName;                                   
        symbol =coinSymbol;   
    }
   function totalSupply()  public  returns (uint256 totalSupply) {
        return _totalSupply;
    }
    function () {
        revert();
    }
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balanceOf[msg.sender] >= _amount
            && _amount > 0) {            
            balanceOf[msg.sender] -= uint112(_amount);
            balanceOf[_to] = _amount.add(balanceOf[_to]).toUINT112();
            soldToken = _amount.add(soldToken).toUINT112();
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balanceOf[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {
            balanceOf[_from] = balanceOf[_from].sub(_amount).toUINT112();
            allowed[_from][msg.sender] -= _amount;
            balanceOf[_to] = _amount.add(balanceOf[_to]).toUINT112();
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function mint(address _owner, uint256 _amount) onlyOwner{
            balanceOf[_owner] = _amount.add(balanceOf[_owner]).toUINT112();
            mintCount =  _amount.add(mintCount).toUINT112();
            _totalSupply = _totalSupply.add(_amount).toUINT112();
    }
  function burn(uint256 _count) public returns (bool success)
  {
          balanceOf[msg.sender] -=uint112( _count);
          deleteToken = _count.add(deleteToken).toUINT112();
         _totalSupply = _totalSupply.sub(_count).toUINT112();
          Burn(msg.sender, _count);
		  return true;
    }
  }
