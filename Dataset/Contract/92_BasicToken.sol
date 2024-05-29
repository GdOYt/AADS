contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  mapping (address => bool) public frozenAccount;
  event FrozenFunds(
      address target, 
      bool frozen
      );
  event Burn(
        address indexed burner, 
        uint256 value
        );
   function burnTokens(address _who, uint256 _amount) public onlyOwner {
       require(balances[_who] >= _amount);
       balances[_who] = balances[_who].sub(_amount);
       totalSupply = totalSupply.sub(_amount);
       emit Burn(_who, _amount);
       emit Transfer(_who, address(0), _amount);
   }
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
  function transfer(address _to, uint256 _value)public returns (bool) {
    require(!frozenAccount[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function balanceOf(address _owner)public constant returns (uint256 balance) {
    return balances[_owner];
  }
}
