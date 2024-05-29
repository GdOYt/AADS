contract NewUpgradeAgent is SafeMath {
    bool public isUpgradeAgent = false;
    address public owner;
    bool public upgradeHasBegun = false;
    bool public finalizedUpgrade = false;
    OldToken public oldToken;
    address public decentBetMultisig;
    NewDecentBetToken public newToken;
    uint256 public originalSupply;  
    uint256 public correctOriginalSupply;  
    uint256 public mintedPercentOfTokens = 30;  
    uint256 public crowdfundPercentOfTokens = 70;
    uint256 public mintedTokens;
    event NewTokenSet(address token);
    event UpgradeHasBegun();
    event InvariantCheckFailed(uint oldTokenSupply, uint newTokenSupply, uint originalSupply, uint value);
    event InvariantCheckPassed(uint oldTokenSupply, uint newTokenSupply, uint originalSupply, uint value);
    function NewUpgradeAgent(address _oldToken) {
        owner = msg.sender;
        isUpgradeAgent = true;
        oldToken = OldToken(_oldToken);
        if (!oldToken.isDecentBetToken()) revert();
        decentBetMultisig = oldToken.decentBetMultisig();
        originalSupply = oldToken.totalSupply();
        mintedTokens = safeDiv(safeMul(originalSupply, mintedPercentOfTokens), crowdfundPercentOfTokens);
        correctOriginalSupply = safeAdd(originalSupply, mintedTokens);
    }
    function safetyInvariantCheck(uint256 _value) public {
        if (!newToken.isNewToken()) revert();
        uint oldSupply = oldToken.totalSupply();
        uint newSupply = newToken.totalSupply();
        if (safeAdd(oldSupply, newSupply) != safeSub(correctOriginalSupply, _value)) {
            InvariantCheckFailed(oldSupply, newSupply, correctOriginalSupply, _value);
        } else {
            InvariantCheckPassed(oldSupply, newSupply, correctOriginalSupply, _value);
        }
    }
    function setNewToken(address _newToken) external {
        if (msg.sender != owner) revert();
        if (_newToken == 0x0) revert();
        if (upgradeHasBegun) revert();
        newToken = NewDecentBetToken(_newToken);
        if (!newToken.isNewToken()) revert();
        NewTokenSet(newToken);
    }
    function setUpgradeHasBegun() internal {
        if (!upgradeHasBegun) {
            upgradeHasBegun = true;
            UpgradeHasBegun();
        }
    }
    function upgradeFrom(address _from, uint256 _value) public {
        if(finalizedUpgrade) revert();
        if (msg.sender != address(oldToken)) revert();
        if (_from == decentBetMultisig) revert();
        if (!newToken.isNewToken()) revert();
        setUpgradeHasBegun();
        safetyInvariantCheck(_value);
        newToken.createToken(_from, _value);
        safetyInvariantCheck(0);
    }
    function setOriginalSupply() public {
        if (msg.sender != address(oldToken)) revert();
        originalSupply = oldToken.totalSupply();
    }
    function finalizeUpgrade() public {
        if (msg.sender != address(oldToken)) revert();
        finalizedUpgrade = true;
    }
    function() {revert();}
}
