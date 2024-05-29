contract NewDecentBetToken is ERC20, SafeMath {
    bool public isDecentBetToken;
    string public constant name = "Decent.Bet Token";
    string public constant symbol = "DBET";
    uint256 public constant decimals = 18;   
    uint256 public constant housePercentOfTotal = 10;
    uint256 public constant vaultPercentOfTotal = 18;
    uint256 public constant bountyPercentOfTotal = 2;
    uint256 public constant crowdfundPercentOfTotal = 70;
    bool public isNewToken = false;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    NewUpgradeAgent public upgradeAgent;
    NextUpgradeAgent public nextUpgradeAgent;
    bool public finalizedNextUpgrade = false;
    address public nextUpgradeMaster;
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);
    event UpgradeFinalized(address sender, address nextUpgradeAgent);
    event UpgradeAgentSet(address agent);
    uint256 public totalUpgraded;
    OldToken public oldToken;
    address public decentBetMultisig;
    uint256 public oldTokenTotalSupply;
    NewDecentBetVault public timeVault;
    function NewDecentBetToken(address _upgradeAgent,
    address _oldToken, address _nextUpgradeMaster) public {
        isNewToken = true;
        isDecentBetToken = true;
        if (_upgradeAgent == 0x0) revert();
        upgradeAgent = NewUpgradeAgent(_upgradeAgent);
        if (_nextUpgradeMaster == 0x0) revert();
        nextUpgradeMaster = _nextUpgradeMaster;
        oldToken = OldToken(_oldToken);
        if (!oldToken.isDecentBetToken()) revert();
        oldTokenTotalSupply = oldToken.totalSupply();
        decentBetMultisig = oldToken.decentBetMultisig();
        if (!MultiSigWallet(decentBetMultisig).isMultiSigWallet()) revert();
        timeVault = new NewDecentBetVault(decentBetMultisig);
        if (!timeVault.isDecentBetVault()) revert();
        uint256 vaultTokens = safeDiv(safeMul(oldTokenTotalSupply, vaultPercentOfTotal),
        crowdfundPercentOfTotal);
        balances[timeVault] = safeAdd(balances[timeVault], vaultTokens);
        Transfer(0, timeVault, vaultTokens);
        uint256 houseTokens = safeDiv(safeMul(oldTokenTotalSupply, housePercentOfTotal),
        crowdfundPercentOfTotal);
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], houseTokens);
        Transfer(0, decentBetMultisig, houseTokens);
        uint256 bountyTokens = safeDiv(safeMul(oldTokenTotalSupply, bountyPercentOfTotal),
        crowdfundPercentOfTotal);
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], bountyTokens);
        Transfer(0, decentBetMultisig, bountyTokens);
        totalSupply = safeAdd(safeAdd(vaultTokens, houseTokens), bountyTokens);
    }
    function createToken(address _target, uint256 _amount) public {
        if (msg.sender != address(upgradeAgent)) revert();
        if (_amount == 0) revert();
        balances[_target] = safeAdd(balances[_target], _amount);
        totalSupply = safeAdd(totalSupply, _amount);
        Transfer(_target, _target, _amount);
    }
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
        if (_to == address(upgradeAgent)) revert();
        if (_to == address(this)) revert();
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {return false;}
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
        if (_to == address(upgradeAgent)) revert();
        if (_to == address(this)) revert();
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_to] = safeAdd(balances[_to], _value);
            balances[_from] = safeSub(balances[_from], _value);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        }
        else {return false;}
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function upgrade(uint256 value) external {
        if (nextUpgradeAgent.owner() == 0x0) revert();
        if (finalizedNextUpgrade) revert();
        if (value == 0) revert();
        if (value > balances[msg.sender]) revert();
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);
        nextUpgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, nextUpgradeAgent, value);
    }
    function setNextUpgradeAgent(address agent) external {
        if (agent == 0x0) revert();
        if (msg.sender != nextUpgradeMaster) revert();
        nextUpgradeAgent = NextUpgradeAgent(agent);
        if (!nextUpgradeAgent.isUpgradeAgent()) revert();
        nextUpgradeAgent.setOriginalSupply();
        UpgradeAgentSet(nextUpgradeAgent);
    }
    function setNextUpgradeMaster(address master) external {
        if (master == 0x0) revert();
        if (msg.sender != nextUpgradeMaster) revert();
        nextUpgradeMaster = master;
    }
    function finalizeNextUpgrade() external {
        if (nextUpgradeAgent.owner() == 0x0) revert();
        if (msg.sender != nextUpgradeMaster) revert();
        if (finalizedNextUpgrade) revert();
        finalizedNextUpgrade = true;
        nextUpgradeAgent.finalizeUpgrade();
        UpgradeFinalized(msg.sender, nextUpgradeAgent);
    }
    function() {revert();}
}
