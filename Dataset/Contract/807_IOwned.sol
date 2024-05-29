contract IOwned {
    function owner() public view returns (address) {}
    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}
