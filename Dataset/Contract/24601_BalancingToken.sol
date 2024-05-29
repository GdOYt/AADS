contract BalancingToken is ERC20 {
    mapping (address => uint256) public balances;       
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}
