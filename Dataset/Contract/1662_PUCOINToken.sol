contract PUCOINToken is PausableToken {
    string  public  constant name = "PUCOIN";
    string  public  constant symbol = "PUB";
    uint8   public  constant decimals = 18;
    modifier validDestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }
    function PUCOINToken( address _admin, uint _totalTokenAmount ) 
    {
        admin = _admin;
        totalSupply = _totalTokenAmount;
        balances[msg.sender] = _totalTokenAmount;
        Transfer(address(0x0), msg.sender, _totalTokenAmount);
    }
    function transfer(address _to, uint _value) validDestination(_to) returns (bool) 
    {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint _value) validDestination(_to) returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }
    event Burn(address indexed _burner, uint _value);
    function burn(uint _value) returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value) returns (bool) 
    {
        assert( transferFrom( _from, msg.sender, _value ) );
        return burn(_value);
    }
    function emergencyERC20Drain( ERC20 token, uint amount ) onlyOwner {
        token.transfer( owner, amount );
    }
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
    function changeAdmin(address newAdmin) onlyOwner {
        AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }
}
