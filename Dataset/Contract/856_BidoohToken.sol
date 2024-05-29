contract BidoohToken is MintableToken {
    string public constant name = "Bidooh Token";
    string public constant symbol = "DOOH";
    uint8 public constant decimals = 18;
    address public teamTokensAddress;
    address public reserveTokensAddress;
    address public saleTokensAddress;
    address public bidoohAdminAddress;
    bool public saleClosed = false;
    modifier beforeSaleClosed {
        require(!saleClosed);
        _;
    }
    constructor(address _teamTokensAddress, address _reserveTokensAddress,
                address _saleTokensAddress, address _bidoohAdminAddress) public {
        require(_teamTokensAddress != address(0));
        require(_reserveTokensAddress != address(0));
        require(_saleTokensAddress != address(0));
        require(_bidoohAdminAddress != address(0));
        teamTokensAddress = _teamTokensAddress;
        reserveTokensAddress = _reserveTokensAddress;
        saleTokensAddress = _saleTokensAddress;
        bidoohAdminAddress = _bidoohAdminAddress;
        uint256 saleTokens = 88200000000 * 10**uint256(decimals);
        totalSupply_ = saleTokens;
        balances[saleTokensAddress] = saleTokens;
        uint256 reserveTokens = 18900000000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(reserveTokens);
        balances[reserveTokensAddress] = reserveTokens;
        uint256 teamTokens = 18900000000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(teamTokens);
        balances[teamTokensAddress] = teamTokens;
    }
    function close() public onlyOwner beforeSaleClosed {
        uint256 unsoldTokens = balances[saleTokensAddress];
        balances[reserveTokensAddress] = balances[reserveTokensAddress].add(unsoldTokens);
        balances[saleTokensAddress] = 0;
        emit Transfer(saleTokensAddress, reserveTokensAddress, unsoldTokens);
        owner = bidoohAdminAddress;
        saleClosed = true;
    }
}
