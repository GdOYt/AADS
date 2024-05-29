contract StandardToken is ERC223 {
    using SafeMath for uint;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
        if(isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = balanceOf(msg.sender).sub(_value);
            balances[_to] = balanceOf(_to).add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return transferToAddress(_to, _value);
        }
    }
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value);
        }
    }
    function transfer(address _to, uint _value) public returns (bool success) {
        bytes memory empty;
        if(isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value);
        }
    }
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
    function transferToAddress(address _to, uint _value) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
      function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(
        address _from, 
        address _to,
        uint _value
    ) 
        public 
        returns (bool)
    {
        if (balanceOf(_from) < _value && allowance(_from, msg.sender) < _value) revert();
        bytes memory empty;
        balances[_to] = balanceOf(_to).add(_value);
        balances[_from] = balanceOf(_from).sub(_value);
        allowed[_from][msg.sender] = allowance(_from, msg.sender).sub(_value);
        if (isContract(_to)) {
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(_from, _to, _value);
        return true;
    }
    function increaseApproval(
        address spender,
        uint value
    )
        public
        returns (bool) 
    {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);
        return true;
    }
    function decreaseApproval(
        address spender,
        uint value
    )
        public
        returns (bool) 
    {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);
        return true;
    }
    function balanceOf(
        address owner
    ) 
        public 
        constant 
        returns (uint) 
    {
        return balances[owner];
    }
    function allowance(
        address owner, 
        address spender
    )
        public
        constant
        returns (uint remaining)
    {
        return allowed[owner][spender];
    }
}
