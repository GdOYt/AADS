contract Burnable is StandardToken {
    using SafeMath for uint;
    event Burn(address indexed from, uint256 value);
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Burn(_from, _value);
        return true;
    }
    function transfer(address _to, uint _value) public returns (bool success) {
        require(_to != 0x0);
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(_to != 0x0);
        return super.transferFrom(_from, _to, _value);
    }
}
