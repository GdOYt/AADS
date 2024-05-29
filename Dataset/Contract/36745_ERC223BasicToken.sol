contract ERC223BasicToken is ERC223Basic{
    using SafeMath for uint;
    mapping(address => uint) balances;
    function transfer(address to, uint value, bytes data) {
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
        Transfer(msg.sender, to, value, data);
    }
    function transfer(address to, uint value) {
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(to)
        }
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, empty);
        }
        Transfer(msg.sender, to, value, empty);
    }
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
}
