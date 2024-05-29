contract Firetoken is StandardToken {
    using SafeMath for uint256;
    mapping (address => uint256) public freezed;
    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Withdraw(address indexed _from, address indexed _to, uint256 _value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
    function burn(uint256 _value) public onlyOwner whenNotPaused {
        _burn(msg.sender, _value);
    }
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    function burnFrom(address _from, uint256 _value) public onlyOwner whenNotPaused {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }
    function mint(address _to, uint256 _amount) public onlyOwner whenNotPaused returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    function freeze(address _spender,uint256 _value) public onlyOwner whenNotPaused returns (bool success) {
        require(_value < balances[_spender]);
        require(_value >= 0); 
        balances[_spender] = balances[_spender].sub(_value);                     
        freezed[_spender] = freezed[_spender].add(_value);                               
        emit Freeze(_spender, _value);
        return true;
    }
    function unfreeze(address _spender,uint256 _value) public onlyOwner whenNotPaused returns (bool success) {
        require(freezed[_spender] < _value);
        require(_value <= 0); 
        freezed[_spender] = freezed[_spender].sub(_value);                      
        balances[_spender] = balances[_spender].add(_value);
        emit Unfreeze(_spender, _value);
        return true;
    }
    function withdrawEther(address _account) public onlyOwner whenNotPaused payable returns (bool success) {
        _account.transfer(address(this).balance);
        emit Withdraw(this, _account, address(this).balance);
        return true;
    }
    function() public payable {
    }
}
