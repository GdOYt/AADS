contract StrongHandsManager {
    event CreateStrongHand(address indexed owner, address indexed strongHand);
    event MintToken(address indexed owner, uint256 indexed amount);
    mapping (address => address) public strongHands;
    mapping (address => uint256) public ownerToBalance;
    string public constant name = "Stronghands3D";
    string public constant symbol = "S3D";
    uint8 public constant decimals = 18;
    uint256 internal tokenSupply = 0;
    function getStrong()
        public
    {
        require(strongHands[msg.sender] == address(0), "you already became a Stronghand");
        strongHands[msg.sender] = new StrongHand(msg.sender);
        emit CreateStrongHand(msg.sender, strongHands[msg.sender]);
    }
    function mint(address _owner, uint256 _amount)
        external
    {
        require(strongHands[_owner] == msg.sender);
        tokenSupply+= _amount;
        ownerToBalance[_owner]+= _amount;
        emit MintToken(_owner, _amount);
    }
    function totalSupply()
        public
        view
        returns (uint256)
    {
       return tokenSupply;
    }
    function balanceOf(address _owner)
        public
        view
        returns (uint256)
    {
        return ownerToBalance[_owner];
    }
}
