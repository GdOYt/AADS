contract TokenData is Owned {
    uint256 public supply;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public approvals;
    address logic;
    modifier onlyLogic {
        assert(msg.sender == logic);
        _;
    }
    function TokenData(address logic_, address owner_) public {
        logic = logic_;
        owner = owner_;
        balances[owner] = supply;
    }
    function setTokenLogic(address logic_) public onlyLogic {
        logic = logic_;
    }
    function setSupply(uint256 supply_) public onlyLogic {
        supply = supply_;
    }
    function setBalances(address guy, uint256 balance) public onlyLogic {
        balances[guy] = balance;
    }
    function setApprovals(address src, address guy, uint256 wad) public onlyLogic {
        approvals[src][guy] = wad;
    }
}
