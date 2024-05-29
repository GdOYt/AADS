contract LATPToken is StandardToken, SafeMath {
    address     public founder;
    address     public minter;
    string      public name             =       "LATO PreICO";
    uint8       public decimals         =       6;
    string      public symbol           =       "LATP";
    string      public version          =       "0.7.1";
    uint        public maxTotalSupply   =       100000 * 1000000;
    modifier onlyFounder() {
        if (msg.sender != founder) {
            throw;
        }
        _;
    }
    modifier onlyMinter() {
        if (msg.sender != minter) {
            throw;
        }
        _;
    }
    function issueTokens(address _for, uint tokenCount)
        external
        payable
        onlyMinter
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }
        if (add(totalSupply, tokenCount) > maxTotalSupply) {
            throw;
        }
        totalSupply = add(totalSupply, tokenCount);
        balances[_for] = add(balances[_for], tokenCount);
        Issuance(_for, tokenCount);
        return true;
    }
    function burnTokens(address _for, uint tokenCount)
        external
        onlyMinter
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }
        if (sub(totalSupply, tokenCount) > totalSupply) {
            throw;
        }
        if (sub(balances[_for], tokenCount) > balances[_for]) {
            throw;
        }
        totalSupply = sub(totalSupply, tokenCount);
        balances[_for] = sub(balances[_for], tokenCount);
        Burn(_for, tokenCount);
        return true;
    }
    function changeMinter(address newAddress)
        public
        onlyFounder
        returns (bool)
    {   
        minter = newAddress;
    }
    function changeFounder(address newAddress)
        public
        onlyFounder
        returns (bool)
    {   
        founder = newAddress;
    }
    function () {
        throw;
    }
    function LATPToken() {
        founder = msg.sender;
        totalSupply = 0;  
    }
}
