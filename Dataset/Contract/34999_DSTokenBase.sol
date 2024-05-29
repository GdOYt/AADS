contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;
    function DSTokenBase(uint supply) {
        _balances[msg.sender] = supply;
        _supply = supply;
    }
    function totalSupply() constant returns (uint) {
        return _supply;
    }
    function balanceOf(address src) constant returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) constant returns (uint) {
        return _approvals[src][guy];
    }
    function transfer(address dst, uint wad) returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) returns (bool) {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);
        Transfer(src, dst, wad);
        return true;
    }
    function approve(address guy, uint wad) returns (bool) {
        _approvals[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }
}
