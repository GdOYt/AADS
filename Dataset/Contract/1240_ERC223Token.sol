contract ERC223Token is ERC223Basic {
    using SafeMath for uint256;
    mapping(address => uint256) balances;  
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }
    function transfer(address _to, uint _value, bytes _data) public onlyPayloadSize(3) {
        uint codeLength;
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(transfersEnabled);
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }
    function transfer(address _to, uint _value) public onlyPayloadSize(2) returns(bool) {
        uint codeLength;
        bytes memory empty;
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(transfersEnabled);
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}
