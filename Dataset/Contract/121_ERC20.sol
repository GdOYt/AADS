contract ERC20 is ERC20Interface,SafeMath {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowed;
    constructor(string _name) public {
       name = _name;  
       symbol = "FEB";
       decimals = 4;
       totalSupply = 10000000000000;
       balanceOf[msg.sender] = totalSupply;
    }
  function transfer(address _to, uint256 _value) returns (bool success) {
      require(_to != address(0));
      require(balanceOf[msg.sender] >= _value);
      require(balanceOf[ _to] + _value >= balanceOf[ _to]);  
      balanceOf[msg.sender] =SafeMath.safeSub(balanceOf[msg.sender],_value) ;
      balanceOf[_to] =SafeMath.safeAdd(balanceOf[_to] ,_value);
      emit Transfer(msg.sender, _to, _value);
      return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      require(_to != address(0));
      require(allowed[_from][msg.sender] >= _value);
      require(balanceOf[_from] >= _value);
      require(balanceOf[ _to] + _value >= balanceOf[ _to]);
      balanceOf[_from] =SafeMath.safeSub(balanceOf[_from],_value) ;
      balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to],_value);
      allowed[_from][msg.sender] =SafeMath.safeSub(allowed[_from][msg.sender], _value);
      emit Transfer(msg.sender, _to, _value);
      return true;
  }
  function approve(address _spender, uint256 _value) returns (bool success) {
      allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
  }
  function allowance(address _owner, address _spender) view returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }
}
