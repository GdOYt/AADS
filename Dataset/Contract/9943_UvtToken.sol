contract UvtToken is PausableToken {
    uint256 public tokenDestroyed;
    address public devTeam;
    address public investor;
    address public ecoBuilder;
    event Burn(address indexed _from, uint256 _tokenDestroyed, uint256 _timestamp);
    function initializeSomeAddress(address newDevTeam, address newInvestor, address newEcoBuilder) onlyOwner public {
        require(newDevTeam != address(0) && newInvestor != address(0) && newEcoBuilder != address(0));
        require(devTeam == 0x0 && investor == 0x0 && ecoBuilder == 0x0);
        devTeam = newDevTeam;
        investor = newInvestor;
        ecoBuilder = newEcoBuilder;
    }
    function burn(uint256 _burntAmount) onlyOwner public returns (bool success) {
        require(balances[msg.sender] >= _burntAmount && _burntAmount > 0);
        balances[msg.sender] = balances[msg.sender].sub(_burntAmount);
        totalSupply = totalSupply.sub(_burntAmount);
        tokenDestroyed = tokenDestroyed.add(_burntAmount);
        require(tokenDestroyed < 10000000000 * (10 ** (uint256(decimals))));
        emit Transfer(address(this), 0x0, _burntAmount);
        emit Burn(msg.sender, _burntAmount, block.timestamp);
        return true;
    }
    string public name = "User Value Token";
    string public symbol = "UVT";
    string public version = '1.0.0';
    uint8 public decimals = 18;
    constructor() public{
        totalSupply = 10000000000 * (10 ** (uint256(decimals)));
        balances[msg.sender] = totalSupply;
    }
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        if (devTeam != 0x0 && _to == devTeam)
        {
            require(balances[_to].add(_value) <= totalSupply.div(5));
        }
        if (investor != 0x0 && _to == investor)
        {
            require(balances[_to].add(_value) <= totalSupply.div(5));
        }
        if (ecoBuilder != 0x0 && _to == ecoBuilder)
        {
            require(balances[_to].add(_value) <= totalSupply.div(5));
        }
        return super.transfer(_to, _value);
    }
}
