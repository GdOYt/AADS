contract StrongHand {
    HourglassInterface constant p3dContract = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
    StrongHandsManagerInterface strongHandManager;
    address public owner;
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
         uint256 amountPurchased = p3dContract.buy.value(_amount)(_referrer);
         strongHandManager.mint(owner, amountPurchased);
    }
    function withdraw()
        external
        onlyOwner
    {
        p3dContract.withdraw();
        owner.transfer(address(this).balance);
    }
}
