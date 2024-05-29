contract AppCoins {
    mapping (address => mapping (address => uint256)) public allowance;
    function balanceOf (address _owner) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (uint);
}
