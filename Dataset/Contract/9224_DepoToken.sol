contract DepoToken is StandardToken, BurnableToken, Owned {
    string public constant name = "Depository Network Token";
    string public constant symbol = "DEPO";
    uint8 public constant decimals = 18;
    uint256 public constant HARD_CAP = 3000000000 * 10**uint256(decimals);
    address public saleTokensAddress;
    address public bountyTokensAddress;
    address public reserveTokensAddress;
    address public teamTokensAddress;
    address public advisorsTokensAddress;
    TokenTimelock public teamTokensLock;
    bool public saleClosed = false;
    mapping(address => bool) public whitelisted;
    modifier beforeEnd {
        require(!saleClosed);
        _;
    }
    constructor(address _teamTokensAddress, address _advisorsTokensAddress, address _reserveTokensAddress,
                address _saleTokensAddress, address _bountyTokensAddress) public {
        require(_teamTokensAddress != address(0));
        require(_advisorsTokensAddress != address(0));
        require(_reserveTokensAddress != address(0));
        require(_saleTokensAddress != address(0));
        require(_bountyTokensAddress != address(0));
        teamTokensAddress = _teamTokensAddress;
        advisorsTokensAddress = _advisorsTokensAddress;
        reserveTokensAddress = _reserveTokensAddress;
        saleTokensAddress = _saleTokensAddress;
        bountyTokensAddress = _bountyTokensAddress;
        whitelisted[saleTokensAddress] = true;
        whitelisted[bountyTokensAddress] = true;
        uint256 saleTokens = 1500000000 * 10**uint256(decimals);
        totalSupply_ = saleTokens;
        balances[saleTokensAddress] = saleTokens;
        emit Transfer(address(0), saleTokensAddress, saleTokens);
        uint256 bountyTokens = 180000000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(bountyTokens);
        balances[bountyTokensAddress] = bountyTokens;
        emit Transfer(address(0), bountyTokensAddress, bountyTokens);
        uint256 reserveTokens = 780000000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(reserveTokens);
        balances[reserveTokensAddress] = reserveTokens;
        emit Transfer(address(0), reserveTokensAddress, reserveTokens);
        uint256 teamTokens = 360000000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(teamTokens);
        teamTokensLock = new TokenTimelock(this, teamTokensAddress, uint64(now + 2 * 365 days));
        balances[address(teamTokensLock)] = teamTokens;
        emit Transfer(address(0), address(teamTokensLock), teamTokens);
        uint256 advisorsTokens = 180000000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(advisorsTokens);
        balances[advisorsTokensAddress] = advisorsTokens;
        emit Transfer(address(0), advisorsTokensAddress, advisorsTokens);
        require(totalSupply_ <= HARD_CAP);
    }
    function close() public onlyOwner beforeEnd {
        saleClosed = true;
    }
    function whitelist(address _address) external onlyOwner {
        whitelisted[_address] = true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if(!saleClosed) return false;
        return super.transferFrom(_from, _to, _value);
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        if(!saleClosed && !whitelisted[msg.sender]) return false;
        return super.transfer(_to, _value);
    }
}
