contract ERC223Token is ERC223TokenInterface, SafeMath {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    function name() constant returns (string _name) {
        return name;
    }
    function symbol() constant returns (string _symbol) {
        return symbol;
    }
    function decimals() constant returns (uint8 _decimals) {
        return decimals;
    }
    function totalSupply() constant returns (uint256 _supply) {
        return totalSupply;
    }
    function balanceOf(address _owner) constant returns (uint256 _balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool _success) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 _remaining) {
        return allowances[_owner][_spender];
    }
    function transfer(address _to, uint256 _value) returns (bool _success) {
        bytes memory emptyMetadata;
        __transfer(msg.sender, _to, _value, emptyMetadata);
        return true;
    }
    function transfer(address _to, uint256 _value, bytes _metadata) returns (bool _success)
    {
        __transfer(msg.sender, _to, _value, _metadata);
        Transfer(msg.sender, _to, _value, _metadata);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool _success) {
        if (allowances[_from][msg.sender] < _value) throw;
        allowances[_from][msg.sender] = safeSub(allowances[_from][msg.sender], _value);
        bytes memory emptyMetadata;
        __transfer(_from, _to, _value, emptyMetadata);
        return true;
    }
    function __transfer(address _from, address _to, uint256 _value, bytes _metadata) internal
    {
        if (_from == _to) throw;
        if (_value == 0) throw;
        if (balanceOf(_from) < _value) throw;
        balances[_from] = safeSub(balanceOf(_from), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        if (isContract(_to)) {
            ERC223ContractInterface receiverContract = ERC223ContractInterface(_to);
            receiverContract.erc223Fallback(_from, _value, _metadata);
        }
        Transfer(_from, _to, _value);
    }
    function isContract(address _addr) internal returns (bool _isContract) {
        _addr = _addr;  
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
}
