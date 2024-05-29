contract Frozen is Pausable {
    event FrozenFunds(address target, bool frozen);
    mapping (address => bool) public frozenAccount;
    function freezeAccount(address target, bool freeze) onlyOwner whenNotPaused public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    modifier whenNotFrozen() {
        require(!frozenAccount[msg.sender]);
        _;
    }
}
