contract IdeaCoin is ERC20Basic("IDC", "IdeaCoin", 18, 1000000000000000000000000), ERC827Token, PausableToken, Destructible, Contactable, HasNoTokens, HasNoContracts {
    using SafeMath for uint;
    event Burn(address _from, uint256 _value);
    event Mint(address _to, uint _value);
      function IdeaCoin() public {
            _balanceOf[msg.sender] = _totalSupply;
        }
       function totalSupply() public constant returns (uint) {
           return _totalSupply;
       }
       function balanceOf(address _addr) public constant returns (uint) {
           return _balanceOf[_addr];
       }
        function burn(address _from, uint256 _value) onlyOwner external {
              require(_balanceOf[_from] >= 0);
              _balanceOf[_from] =  _balanceOf[_from].sub(_value);
              _totalSupply = _totalSupply.sub(_value);
              emit Burn(_from, _value);
            }
        function mintToken(address _to, uint256 _value) onlyOwner external  {
                require(!frozenAccount[msg.sender] && !frozenAccount[_to]);
               _balanceOf[_to] = _balanceOf[_to].add(_value);
               _totalSupply = _totalSupply.add(_value);
               emit Mint(_to,_value);
             }
}
