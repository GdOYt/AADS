contract ERC20Basic {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function totalSupply() public view returns (uint256);
}
