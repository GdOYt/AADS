contract TokenSafe {
    using SafeMath for uint;
    ERC20Token token;
    struct Group {
        uint256 releaseTimestamp;
        uint256 remaining;
        mapping (address => uint) balances;
    }
    mapping (uint8 => Group) public groups;
    constructor(address _token) public {
        token = ERC20Token(_token);
    }
    function init(uint8 _id, uint _releaseTimestamp) internal {
        require(_releaseTimestamp > 0);
        Group storage group = groups[_id];
        group.releaseTimestamp = _releaseTimestamp;
    }
    function add(uint8 _id, address _account, uint _balance) internal {
        Group storage group = groups[_id];
        group.balances[_account] = group.balances[_account].plus(_balance);
        group.remaining = group.remaining.plus(_balance);
    }
    function release(uint8 _id, address _account) public {
        Group storage group = groups[_id];
        require(now >= group.releaseTimestamp);
        uint tokens = group.balances[_account];
        require(tokens > 0);
        group.balances[_account] = 0;
        group.remaining = group.remaining.minus(tokens);
        if (!token.transfer(_account, tokens)) {
            revert();
        }
    }
}
