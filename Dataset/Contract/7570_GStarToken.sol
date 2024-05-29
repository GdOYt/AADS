contract GStarToken is StandardToken, Ownable {
    using SafeMath for uint256;
    string public constant name = "GSTAR Token";
    string public constant symbol = "GSTAR";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1600000000 * ((10 ** uint256(decimals)));
    uint256 public currentTotalSupply = 0;
    event Burn(address indexed burner, uint256 value);
    function GStarToken() public {
        owner = msg.sender;
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = INITIAL_SUPPLY;
        currentTotalSupply = INITIAL_SUPPLY;
        emit Transfer(address(0), owner, INITIAL_SUPPLY);
    }
    function burn(uint256 value) public onlyOwner {
        require(value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(value);
        currentTotalSupply = currentTotalSupply.sub(value);
        emit Burn(burner, value);
    }
}
