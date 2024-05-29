contract Token is Owned {
    using SafeMath for uint256;
    string  public name = "Inlock token";
    string  public symbol = "ILK";
    uint8   public decimals = 8;
    uint256 public totalSupply = 44e16;
    address public libAddress;
    TokenDB public db;
    Ico public ico;
    function () public { revert(); }
    function changeLibAddress(address _libAddress) external forOwner {}
    function changeDBAddress(address _dbAddress) external forOwner {}
    function changeIcoAddress(address _icoAddress) external forOwner {}
    function approve(address _spender, uint256 _value) external returns (bool _success) {}
    function transfer(address _to, uint256 _amount) external returns (bool _success) {}
    function bulkTransfer(address[] _to, uint256[] _amount) external returns (bool _success) {}
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool _success) {}
    function allowance(address _owner, address _spender) public view returns (uint256 _remaining) {}
    function balanceOf(address _owner) public view returns (uint256 _balance) {}
    event AllowanceUsed(address indexed _spender, address indexed _owner, uint256 indexed _value);
    event Mint(address indexed _addr, uint256 indexed _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}
