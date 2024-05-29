contract EDOGE is ERC223, SafeMath {
    string public name = "eDogecoin";
    string public symbol = "EDOGE";
    uint8 public decimals = 8;
    uint256 public totalSupply = 100000000000 * 10**8;
    address public owner;
    bool public unlocked = false;
    bool public tokenCreated = false;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    function EDOGE() public {
        require(tokenCreated == false);
        tokenCreated = true;
        owner = msg.sender;
        balances[owner] = totalSupply;
        require(balances[owner] > 0);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function distributeAirdrop(address[] addresses, uint256 amount) onlyOwner public{
        require(balances[owner] >= safeMul(addresses.length, amount));
        for (uint i = 0; i < addresses.length; i++) {
            balances[owner] = safeSub(balanceOf(owner), amount);
            require(balances[owner] >= 0);
            balances[addresses[i]] = safeAdd(balanceOf(addresses[i]), amount);
            transfer(addresses[i], amount);
        }
    }
    function name() constant public returns (string _name) {
        return name;
    }
    function symbol() constant public returns (string _symbol) {
        return symbol;
    }
    function decimals() constant public returns (uint8 _decimals) {
        return decimals;
    }
    function totalSupply() constant public returns (uint256 _totalSupply) {
        return totalSupply;
    }
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
        require(unlocked);
        if (isContract(_to)) {
            if (balanceOf(msg.sender) < _value) {
                revert();
            }
            balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
            balances[_to] = safeAdd(balanceOf(_to), _value);
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }
    function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
        require(unlocked);
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }
    function transfer(address _to, uint _value) public returns (bool success) {
        require(unlocked);
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }
    function isContract(address _addr) private returns (bool is_contract) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) {
            revert();
        }
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) {
            revert();
        }
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    function unlockForever() onlyOwner public {
        unlocked = true;
    }
}
