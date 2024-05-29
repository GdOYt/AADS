contract ERC223Token is StandardToken {
    using SafeMath for uint;
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    modifier enoughBalance(uint _value) {
        require (_value <= balanceOf(msg.sender));
        _;
    }
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
        require(_to != address(0));
        return isContract(_to) ?
            transferToContract(_to, _value, _data) :
            transferToAddress(_to, _value, _data)
        ;
    }
    function transfer(address _to, uint _value) public returns (bool success) {
        bytes memory empty;
        return transfer(_to, _value, empty);
    }
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
    function transferToAddress(address _to, uint _value, bytes _data) private enoughBalance(_value) returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function transferToContract(address _to, uint _value, bytes _data) private enoughBalance(_value) returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        ERC223Receiver receiver = ERC223Receiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
}
