contract Share is HumanStandardToken, Ownable {
    using SafeMath for uint;
    string public constant TOKEN_NAME = "Vyral Token";
    string public constant TOKEN_SYMBOL = "SHARE";
    uint8 public constant TOKEN_DECIMALS = 18;
    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(TOKEN_DECIMALS));
    mapping (address => uint256) lockedBalances;
    mapping (address => bool) public transferrers;
    function Share() HumanStandardToken(TOTAL_SUPPLY, TOKEN_NAME, TOKEN_DECIMALS, TOKEN_SYMBOL)
        public
    {
        transferrers[msg.sender] = true;
    }
    bool isTransferable = false;
    bool isBonusLocked = true;
    modifier canBeTransferred {
        require(transferrers[msg.sender] || isTransferable);
        _;
    }
    function transferReward(
        address _to,
        uint _value
    )
        canBeTransferred
        public
        returns (bool)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        lockedBalances[_to] = lockedBalances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transfer(
        address _to,
        uint _value
    )
        canBeTransferred
        public
        returns (bool)
    {
        require(balances[msg.sender] >= _value);
        if(isBonusLocked) {
            require(balances[msg.sender].sub(lockedBalances[msg.sender]) >= _value);
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(
        address _from,
        address _to,
        uint _value
    )
        canBeTransferred
        public
        returns (bool)
    {
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        if(isBonusLocked) {
            require(balances[_from].sub(lockedBalances[_from]) >= _value);
        }
        allowed[_from][msg.sender] = allowed[_from][_to].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    function lockedBalanceOf(
        address _owner
    )
        constant
        returns (uint)
    {
        return lockedBalances[_owner];
    }
    function enableTransfers()
        onlyOwner
        external
        returns (bool)
    {
        isTransferable = true;
        return isTransferable;
    }
    function addTransferrer(
        address _transferrer
    )
        public
        onlyOwner
    {
        transferrers[_transferrer] = true;
    }
    function releaseBonus()
        public
        onlyOwner
    {
        isBonusLocked = false;
    }
}
