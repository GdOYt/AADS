contract StrongHand {
    HourglassInterface constant p3dContract = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
    StrongHandsManagerInterface strongHandManager;
    address public owner;
    uint256 private p3dBalance = 0;
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    constructor(address _owner)
        public
    {
        owner = _owner;
        strongHandManager = StrongHandsManagerInterface(msg.sender);
    }
    function() public payable {}
    function buy(address _referrer)
        external
        payable
        onlyOwner
    {
        purchase(msg.value, _referrer);
    }
    function purchase(uint256 _amount, address _referrer)
        private
    {
        p3dContract.buy.value(_amount)(_referrer);
        uint256 balance = p3dContract.balanceOf(address(this));
        uint256 diff = balance - p3dBalance;
        p3dBalance = balance;
        strongHandManager.mint(owner, diff);
    }
    function withdraw()
        external
        onlyOwner
    {
        p3dContract.withdraw();
        owner.transfer(address(this).balance);
    }
}
