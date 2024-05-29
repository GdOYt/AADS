contract FBT is ERC20 {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bytes1) addresslevels;
    mapping (address => uint256) feebank;
    uint256 public totalSupply;
    uint256 public pieceprice;
    uint256 public datestart;
    uint256 public totalaccumulated;
    address dev1 = 0xFAB873F0f71dCa84CA33d959C8f017f886E10C63;
    address dev2 = 0xD7E9aB6a7a5f303D3Cd17DcaEFF254D87757a1F8;
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            refundFees();
            return true;
        } else revert();
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            refundFees();
            return true;
        } else revert();
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function refundFees() {
        uint256 refund = 200000*tx.gasprice;
        if (feebank[msg.sender]>=refund) {
            msg.sender.transfer(refund);
            feebank[msg.sender]-=refund;
        }       
    }
}
