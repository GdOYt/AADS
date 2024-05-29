contract ERC20Token {
    using SafeMath for uint256;
    string public constant name = "Ansforce Intelligence Token";
    string public constant symbol = "AIT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, uint256 value, address indexed to, bytes extraData);
    constructor() public {
    }
    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value);
        require(balanceOf[to] + value > balanceOf[to]);
        uint256 previousBalances = balanceOf[from].add(balanceOf[to]);
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
        assert(balanceOf[from].add(balanceOf[to]) == previousBalances);
    }
    function transfer(address to, uint256 value) public {
        _transfer(msg.sender, to, value);
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= allowance[from][msg.sender]);
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
    function approve(address spender, uint256 value, bytes extraData) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, value, spender, extraData);
        return true;
    }
}
