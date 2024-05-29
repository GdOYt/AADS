contract NaorisToken is ReferralDiscountToken {
    string public constant name = "NaorisToken";
    string public constant symbol = "NAO";
    uint256 public constant decimals = 18;
    address public saleTeamAddress;
    address public referalAirdropsTokensAddress;
    address public reserveFundAddress;
    address public thinkTankFundAddress;
    address public lockedBoardBonusAddress;
    address public treasuryTimelockAddress;
    bool public tokenSaleClosed = false;
    uint64 date01May2019 = 1556668800;
    uint256 public constant TOKENS_HARD_CAP = 400000000 * 10 ** decimals;
    uint256 public constant TOKENS_SALE_HARD_CAP = 300000000 * 10 ** decimals;
    uint256 public constant REFERRAL_TOKENS = 10000000 * 10 ** decimals;
    uint256 public constant AIRDROP_TOKENS = 10000000 * 10 ** decimals;
    uint256 public constant THINK_TANK_FUND_TOKENS = 40000000 * 10 ** decimals;
    uint256 public constant NAORIS_TEAM_TOKENS = 20000000 * 10 ** decimals;
    uint256 public constant LOCKED_BOARD_BONUS_TOKENS = 20000000 * 10 ** decimals;
    modifier onlyTeam {
        assert(msg.sender == saleTeamAddress || msg.sender == owner);
        _;
    }
    modifier beforeEnd {
        assert(!tokenSaleClosed);
        _;
    }
    constructor(address _saleTeamAddress, address _referalAirdropsTokensAddress, address _reserveFundAddress,
    address _thinkTankFundAddress, address _lockedBoardBonusAddress) public {
        require(_saleTeamAddress != address(0));
        require(_referalAirdropsTokensAddress != address(0));
        require(_reserveFundAddress != address(0));
        require(_thinkTankFundAddress != address(0));
        require(_lockedBoardBonusAddress != address(0));
        saleTeamAddress = _saleTeamAddress;
        referalAirdropsTokensAddress = _referalAirdropsTokensAddress;
        reserveFundAddress = _reserveFundAddress;
        thinkTankFundAddress = _thinkTankFundAddress;
        lockedBoardBonusAddress = _lockedBoardBonusAddress;
        balances[saleTeamAddress] = TOKENS_SALE_HARD_CAP;
        totalSupply_ = TOKENS_SALE_HARD_CAP;
        emit Transfer(0x0, saleTeamAddress, TOKENS_SALE_HARD_CAP);
        balances[referalAirdropsTokensAddress] = REFERRAL_TOKENS;
        totalSupply_ = totalSupply_.add(REFERRAL_TOKENS);
        emit Transfer(0x0, referalAirdropsTokensAddress, REFERRAL_TOKENS);
        balances[referalAirdropsTokensAddress] = balances[referalAirdropsTokensAddress].add(AIRDROP_TOKENS);
        totalSupply_ = totalSupply_.add(AIRDROP_TOKENS);
        emit Transfer(0x0, referalAirdropsTokensAddress, AIRDROP_TOKENS);
    }
    function close() public onlyTeam beforeEnd {
        uint256 unsoldSaleTokens = balances[saleTeamAddress];
        if(unsoldSaleTokens > 0) {
            balances[saleTeamAddress] = 0;
            totalSupply_ = totalSupply_.sub(unsoldSaleTokens);
            emit Transfer(saleTeamAddress, 0x0, unsoldSaleTokens);
        }
        uint256 unspentReferalAirdropTokens = balances[referalAirdropsTokensAddress];
        if(unspentReferalAirdropTokens > 0) {
            balances[referalAirdropsTokensAddress] = 0;
            balances[reserveFundAddress] = balances[reserveFundAddress].add(unspentReferalAirdropTokens);
            emit Transfer(referalAirdropsTokensAddress, reserveFundAddress, unspentReferalAirdropTokens);
        }
        balances[thinkTankFundAddress] = balances[thinkTankFundAddress].add(THINK_TANK_FUND_TOKENS);
        totalSupply_ = totalSupply_.add(THINK_TANK_FUND_TOKENS);
        emit Transfer(0x0, thinkTankFundAddress, THINK_TANK_FUND_TOKENS);
        balances[owner] = balances[owner].add(NAORIS_TEAM_TOKENS);
        totalSupply_ = totalSupply_.add(NAORIS_TEAM_TOKENS);
        emit Transfer(0x0, owner, NAORIS_TEAM_TOKENS);
        TokenTimelock lockedTreasuryTokens = new TokenTimelock(this, lockedBoardBonusAddress, date01May2019);
        treasuryTimelockAddress = address(lockedTreasuryTokens);
        balances[treasuryTimelockAddress] = balances[treasuryTimelockAddress].add(LOCKED_BOARD_BONUS_TOKENS);
        totalSupply_ = totalSupply_.add(LOCKED_BOARD_BONUS_TOKENS);
        emit Transfer(0x0, treasuryTimelockAddress, LOCKED_BOARD_BONUS_TOKENS);
        require(totalSupply_ <= TOKENS_HARD_CAP);
        tokenSaleClosed = true;
    }
    function tokenDiscountPercentage(address _owner) public view returns (uint256 percent) {
        if(balanceOf(_owner) >= 1000000 * 10**decimals) {
            return 50;
        } else if(balanceOf(_owner) >= 500000 * 10**decimals) {
            return 30;
        } else if(balanceOf(_owner) >= 250000 * 10**decimals) {
            return 25;
        } else if(balanceOf(_owner) >= 100000 * 10**decimals) {
            return 20;
        } else if(balanceOf(_owner) >= 50000 * 10**decimals) {
            return 15;
        } else if(balanceOf(_owner) >= 10000 * 10**decimals) {
            return 10;
        } else if(balanceOf(_owner) >= 1000 * 10**decimals) {
            return 5;
        } else {
            return 0;
        }
    }
    function getTotalDiscount(address _owner) public view returns (uint256 percent) {
        uint256 total = 0;
        total += tokenDiscountPercentage(_owner);
        total += referralDiscountPercentage(_owner);
        return (total > 60) ? 60 : total;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if(tokenSaleClosed) {
            return super.transferFrom(_from, _to, _value);
        }
        return false;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        if(tokenSaleClosed || msg.sender == referalAirdropsTokensAddress
                        || msg.sender == saleTeamAddress) {
            return super.transfer(_to, _value);
        }
        return false;
    }
}
