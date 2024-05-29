contract AdvanceToken is ERC20, owned,SelfDesctructionContract{
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    event Burn(address target, uint amount);
    constructor (string _name) ERC20(_name) public {
    }
  function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
  function transfer(address _to, uint256 _value) public returns (bool success) {
        success = _transfer(msg.sender, _to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowed[_from][msg.sender] >= _value);
        success =  _transfer(_from, _to, _value);
        allowed[_from][msg.sender] =SafeMath.safeSub(allowed[_from][msg.sender],_value) ;
  }
  function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
      require(_to != address(0));
      require(!frozenAccount[_from]);
      require(balanceOf[_from] >= _value);
      require(balanceOf[ _to] + _value >= balanceOf[ _to]);
      balanceOf[_from] =SafeMath.safeSub(balanceOf[_from],_value) ;
      balanceOf[_to] =SafeMath.safeAdd(balanceOf[_to],_value) ;
      emit Transfer(_from, _to, _value);
      return true;
  }
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        totalSupply =SafeMath.safeSub(totalSupply,_value) ;
        balanceOf[msg.sender] =SafeMath.safeSub(balanceOf[msg.sender],_value) ;
        emit Burn(msg.sender, _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value)  public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        totalSupply =SafeMath.safeSub(totalSupply,_value) ;
        balanceOf[msg.sender] =SafeMath.safeSub(balanceOf[msg.sender], _value);
        allowed[_from][msg.sender] =SafeMath.safeSub(allowed[_from][msg.sender],_value);
        emit Burn(msg.sender, _value);
        return true;
    }
}
