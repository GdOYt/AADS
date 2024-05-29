contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;
 mapping (address => bool) public frozenAccount;
 event FrozenFunds(address target, bool frozen);
  uint256 totalSupply_;
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
   function freezeAccount(address target, bool freeze) onlyOwner external {
         frozenAccount[target] = freeze;
         emit FrozenFunds(target, freeze);
         }
  function transfer(address _to, uint256 _value) public returns (bool) {
      require(!frozenAccount[msg.sender]);
    require(_to != address(0));
    require(_value <= _balanceOf[msg.sender]);
    _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
    _balanceOf[_to] = _balanceOf[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _balanceOf[_owner];
  }
}
