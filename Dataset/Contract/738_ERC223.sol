contract ERC223 is Permissioned {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function increaseApproval(address _spender, uint _addedValue) public returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool);
    function transfer(address _to, uint256 _value, bytes _data) public;
}
