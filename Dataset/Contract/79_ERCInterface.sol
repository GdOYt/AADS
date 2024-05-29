contract ERCInterface {
    function transferFrom(address _from, address _to, uint256 _value) public;
    function balanceOf(address who) constant public returns (uint256);
    function allowance(address owner, address spender) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns(bool);
}
