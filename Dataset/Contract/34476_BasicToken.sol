contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    mapping (address => uint256) balances;
    function transfer(address _to, uint256 _value) returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}
