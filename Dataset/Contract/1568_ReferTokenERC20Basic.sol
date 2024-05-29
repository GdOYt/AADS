contract ReferTokenERC20Basic is ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) rewardBalances;
    mapping(address => mapping(address => uint256)) allow;
    function _transfer(address _from, address _to, uint256 _value) private returns (bool) {
        require(_to != address(0));
        require(_value <= rewardBalances[_from]);
        rewardBalances[_from] = rewardBalances[_from].sub(_value);
        rewardBalances[_to] = rewardBalances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return rewardBalances[_owner];
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != msg.sender);
        require(allow[_from][msg.sender] > _value || allow[_from][msg.sender] == _value);
        success = _transfer(_from, _to, _value);
        if (success) {
            allow[_from][msg.sender] = allow[_from][msg.sender].sub(_value);
        }
        return success;
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allow[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allow[_owner][_spender];
    }
}
