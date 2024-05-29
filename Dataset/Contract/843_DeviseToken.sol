contract DeviseToken is CappedToken, BurnableToken, RBACMintableToken {
    string public name = "DEVISE";
    string public symbol = "DVZ";
    uint8 public decimals = 6;
    function DeviseToken(uint256 _cap) public
    CappedToken(_cap) {
        addMinter(owner);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        removeMinter(owner);
        addMinter(newOwner);
        super.transferOwnership(newOwner);
    }
}
