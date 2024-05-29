contract KeyRewardPool is DSStop , DSMath{
    DSToken public key;
    uint public rewardStartTime;
    uint constant public yearlyRewardPercentage = 10;  
    uint public totalRewardThisYear;
    uint public collectedTokens;
    address public withdrawer;
    event TokensWithdrawn(address indexed _holder, uint _amount);
    event LogSetWithdrawer(address indexed _withdrawer);
    modifier onlyWithdrawer {
        require(msg.sender == withdrawer);
        _;
    }
    function KeyRewardPool(uint _rewardStartTime, address _key, address _withdrawer){
        require(_rewardStartTime != 0 );
        require(_key != address(0) );
        require(_withdrawer != address(0) );
        rewardStartTime = _rewardStartTime;
        key = DSToken(_key);
        withdrawer = _withdrawer;
    }
    function collectToken() stoppable onlyWithdrawer{
        uint _time = time();
        var _key = key;   
        require(_time > rewardStartTime);
        uint balance = _key.balanceOf(address(this));
        uint total = add(collectedTokens, balance);
        uint remainingTokens = total;
        uint yearCount = yearFor(_time);
        for(uint i = 0; i < yearCount; i++) {
            remainingTokens =  div( mul(remainingTokens, 100 - yearlyRewardPercentage), 100);
        }
        totalRewardThisYear =  div( mul(remainingTokens, yearlyRewardPercentage), 100);
        uint canExtractThisYear = div( mul(totalRewardThisYear, (_time - rewardStartTime)  % 365 days), 365 days);
        uint canExtract = canExtractThisYear + total - remainingTokens;
        canExtract = sub(canExtract, collectedTokens);
        if(canExtract > balance) {
            canExtract = balance;
        }
        collectedTokens = add(collectedTokens, canExtract);
        assert(_key.transfer(withdrawer, canExtract));  
        TokensWithdrawn(withdrawer, canExtract);
    }
    function yearFor(uint timestamp) constant returns(uint) {
        return timestamp < rewardStartTime
            ? 0
            : sub(timestamp, rewardStartTime) / (365 days);
    }
    function time() constant returns (uint) {
        return now;
    }
    function setWithdrawer(address _withdrawer) auth {
        withdrawer = _withdrawer;
        LogSetWithdrawer(_withdrawer);
    }
    function transferTokens(address dst, uint wad, address _token) public auth note {
        require( _token != address(key));
        if (wad > 0) {
            ERC20 token = ERC20(_token);
            token.transfer(dst, wad);
        }
    }
}
