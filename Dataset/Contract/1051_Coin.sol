contract Coin is ERC20, DSStop {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 internal c_totalSupply;
    mapping(address => uint256) internal c_balances;
    mapping(address => mapping(address => uint256)) internal c_approvals;
    function init(uint256 token_supply, string token_name, string token_symbol) internal {
        c_balances[msg.sender] = token_supply;
        c_totalSupply = token_supply;
        name = token_name;
        symbol = token_symbol;
    }
    function() public {
        assert(false);
    }
    function setName(string _name) auth public {
        name = _name;
    }
    function totalSupply() constant public returns (uint256) {
        return c_totalSupply;
    }
    function balanceOf(address _owner) constant public returns (uint256) {
        return c_balances[_owner];
    }
    function approve(address _spender, uint256 _value) public stoppable returns (bool) {
        require(msg.data.length >= (2 * 32) + 4);
        require(_value == 0 || c_approvals[msg.sender][_spender] == 0);
        require(_value < c_totalSupply);
        c_approvals[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return c_approvals[_owner][_spender];
    }
}
