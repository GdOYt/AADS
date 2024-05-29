contract AirdropToken is BaseToken, Ownable {
    uint256 public airAmount;
    address public airSender;
    uint256 public airLimitCount;
    mapping (address => uint256) public airCountOf;
    event Airdrop(address indexed from, uint256 indexed count, uint256 tokenValue);
    function airdrop() public {
        require(airAmount > 0);
        if (airLimitCount > 0 && airCountOf[msg.sender] >= airLimitCount) {
            revert();
        }
        _transfer(airSender, msg.sender, airAmount);
        airCountOf[msg.sender] = airCountOf[msg.sender].add(1);
        Airdrop(msg.sender, airCountOf[msg.sender], airAmount);
    }
    function changeAirAmount(uint256 newAirAmount) public onlyOwner {
        airAmount = newAirAmount;
    }
    function changeAirLimitCount(uint256 newAirLimitCount) public onlyOwner {
        airLimitCount = newAirLimitCount;
    }
}
