contract ReadOnlyTokenImpl is ReadOnlyToken {
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
