contract HoldToken is MintableToken {
    using SafeMath for uint256;
    string public name = 'HOLD';
    string public symbol = 'HOLD';
    uint8 public decimals = 18;
    event Burn(address indexed burner, uint256 value);
    event BurnTransferred(address indexed previousBurner, address indexed newBurner);
    address burnerRole;
    modifier onlyBurner() {
        require(msg.sender == burnerRole);
        _;
    }
    function HoldToken(address _burner) public {
        burnerRole = _burner;
    }
    function transferBurnRole(address newBurner) public onlyBurner {
        require(newBurner != address(0));
        BurnTransferred(burnerRole, newBurner);
        burnerRole = newBurner;
    }
    function burn(uint256 _value) public onlyBurner {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0), _value);
    }
}
