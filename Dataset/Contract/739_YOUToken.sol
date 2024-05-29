contract YOUToken {
    function mint(address _to, uint256 _amount) public returns (bool);
    function transferOwnership(address _newOwner) public;
}
