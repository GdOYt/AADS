contract LimitCollectCoin is Coin, DSMath {
    struct FreezingNode {
        uint end_stamp;
        uint num_lccs;
        uint8 freezing_type;
    }
    mapping(address => FreezingNode[]) internal c_freezing_list;
    constructor(uint256 token_supply, string token_name, string token_symbol) public {
        init(token_supply, token_name, token_symbol);
        setAuthority(new FreezerAuthority());
    }
    function addFreezer(address freezer) auth public {
        FreezerAuthority(authority).addFreezer(freezer);
    }
    function removeFreezer(address freezer) auth public {
        FreezerAuthority(authority).removeFreezer(freezer);
    }
    event ClearExpiredFreezingEvent(address indexed addr);
    event SetFreezingEvent(address indexed addr, uint end_stamp, uint num_lccs, uint8 indexed freezing_type);
    function clearExpiredFreezing(address addr) public {
        FreezingNode[] storage nodes = c_freezing_list[addr];
        uint length = nodes.length;
        uint left = 0;
        while (left < length) {
            if (nodes[left].end_stamp <= block.timestamp) {
                break;
            }
            left++;
        }
        uint right = left + 1;
        while (left < length && right < length) {
            if (nodes[right].end_stamp > block.timestamp) {
                nodes[left] = nodes[right];
                left++;
            }
            right++;
        }
        if (length != left) {
            nodes.length = left;
            emit ClearExpiredFreezingEvent(addr);
        }
    }
    function validBalanceOf(address addr) constant public returns (uint) {
        FreezingNode[] memory nodes = c_freezing_list[addr];
        uint length = nodes.length;
        uint total_lccs = balanceOf(addr);
        for (uint i = 0; i < length; ++i) {
            if (nodes[i].end_stamp > block.timestamp) {
                total_lccs = sub(total_lccs, nodes[i].num_lccs);
            }
        }
        return total_lccs;
    }
    function freezingBalanceNumberOf(address addr) constant public returns (uint) {
        return c_freezing_list[addr].length;
    }
    function freezingBalanceInfoOf(address addr, uint index) constant public returns (uint, uint, uint8) {
        return (c_freezing_list[addr][index].end_stamp, c_freezing_list[addr][index].num_lccs, uint8(c_freezing_list[addr][index].freezing_type));
    }
    function setFreezing(address addr, uint end_stamp, uint num_lccs, uint8 freezing_type) auth stoppable public {
        require(block.timestamp < end_stamp);
        require(num_lccs < c_totalSupply);
        clearExpiredFreezing(addr);
        uint valid_balance = validBalanceOf(addr);
        require(valid_balance >= num_lccs);
        FreezingNode memory node = FreezingNode(end_stamp, num_lccs, freezing_type);
        c_freezing_list[addr].push(node);
        emit SetFreezingEvent(addr, end_stamp, num_lccs, freezing_type);
    }
    function transferAndFreezing(address _to, uint256 _value, uint256 freeze_amount, uint end_stamp, uint8 freezing_type) auth stoppable public returns (bool) {
        require(_value < c_totalSupply);
        require(freeze_amount <= _value);
        transfer(_to, _value);
        setFreezing(_to, end_stamp, freeze_amount, freezing_type);
        return true;
    }
    function transfer(address _to, uint256 _value) stoppable public returns (bool) {
        require(msg.data.length >= (2 * 32) + 4);
        require(_value < c_totalSupply);
        clearExpiredFreezing(msg.sender);
        uint from_lccs = validBalanceOf(msg.sender);
        require(from_lccs >= _value);
        c_balances[msg.sender] = sub(c_balances[msg.sender], _value);
        c_balances[_to] = add(c_balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) stoppable public returns (bool) {
        require(_value < c_totalSupply);
        require(c_approvals[_from][msg.sender] >= _value);
        clearExpiredFreezing(_from);
        uint from_lccs = validBalanceOf(_from);
        require(from_lccs >= _value);
        c_approvals[_from][msg.sender] = sub(c_approvals[_from][msg.sender], _value);
        c_balances[_from] = sub(c_balances[_from], _value);
        c_balances[_to] = add(c_balances[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}
