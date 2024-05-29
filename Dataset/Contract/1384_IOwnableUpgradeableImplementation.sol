contract IOwnableUpgradeableImplementation is INotInitedOwnable {
    function transferOwnership(address newOwner) public;
    function getOwner() constant public returns(address);
    function upgradeImplementation(address _newImpl) public;
    function getImplementation() constant public returns(address);
}
