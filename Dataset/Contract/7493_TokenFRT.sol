contract TokenFRT is StandardToken {
    string public constant symbol = "MGN";
    string public constant name = "Magnolia Token";
    uint8 public constant decimals = 18;
    struct unlockedToken {
        uint amountUnlocked;
        uint withdrawalTime;
    }
    address public owner;
    address public minter;
    mapping (address => unlockedToken) public unlockedTokens;
    mapping (address => uint) public lockedTokenBalances;
    function TokenFRT(
        address _owner
    )
        public
    {
        require(_owner != address(0));
        owner = _owner;
    }
    function updateMinter(
        address _minter
    )
        public
    {
        require(msg.sender == owner);
        require(_minter != address(0));
        minter = _minter;
    }
    function updateOwner(   
        address _owner
    )
        public
    {
        require(msg.sender == owner);
        require(_owner != address(0));
        owner = _owner;
    }
    function mintTokens(
        address user,
        uint amount
    )
        public
    {
        require(msg.sender == minter);
        lockedTokenBalances[user] = add(lockedTokenBalances[user], amount);
        totalTokens = add(totalTokens, amount);
    }
    function lockTokens(
        uint amount
    )
        public
        returns (uint totalAmountLocked)
    {
        amount = min(amount, balances[msg.sender]);
        balances[msg.sender] = sub(balances[msg.sender], amount);
        lockedTokenBalances[msg.sender] = add(lockedTokenBalances[msg.sender], amount);
        totalAmountLocked = lockedTokenBalances[msg.sender];
    }
    function unlockTokens(
        uint amount
    )
        public
        returns (uint totalAmountUnlocked, uint withdrawalTime)
    {
        amount = min(amount, lockedTokenBalances[msg.sender]);
        if (amount > 0) {
            lockedTokenBalances[msg.sender] = sub(lockedTokenBalances[msg.sender], amount);
            unlockedTokens[msg.sender].amountUnlocked =  add(unlockedTokens[msg.sender].amountUnlocked, amount);
            unlockedTokens[msg.sender].withdrawalTime = now + 24 hours;
        }
        totalAmountUnlocked = unlockedTokens[msg.sender].amountUnlocked;
        withdrawalTime = unlockedTokens[msg.sender].withdrawalTime;
    }
    function withdrawUnlockedTokens()
        public
    {
        require(unlockedTokens[msg.sender].withdrawalTime < now);
        balances[msg.sender] = add(balances[msg.sender], unlockedTokens[msg.sender].amountUnlocked);
        unlockedTokens[msg.sender].amountUnlocked = 0;
    }
    function min(uint a, uint b) 
        public
        pure
        returns (uint)
    {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }
    function safeToAdd(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a + b >= a;
    }
    function safeToSub(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a >= b;
    }
    function add(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToAdd(a, b));
        return a + b;
    }
    function sub(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToSub(a, b));
        return a - b;
    }
}
