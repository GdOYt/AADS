contract NextUpgradeAgent is SafeMath {
    address public owner;
    bool public isUpgradeAgent;
    function upgradeFrom(address _from, uint256 _value) public;
    function finalizeUpgrade() public;
    function setOriginalSupply() public;
}
