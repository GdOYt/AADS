contract StrongHand {
    HourglassInterface constant p3dContract = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
    address public owner;
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    constructor(address _owner, address _referrer)
        public
        payable
    {
        owner = _owner;
        purchase(msg.value, _referrer);
    }
    function() public payable {}
    function buy(address _referrer)
        public
        payable
        onlyOwner
    {
        purchase(msg.value, _referrer);
    }
    function purchase(uint256 amount, address _referrer)
        private
    {
        p3dContract.buy.value(amount)(_referrer);
    }
    function withdraw()
        external
        onlyOwner
    {
        p3dContract.withdraw();
        owner.transfer(address(this).balance);
    }
}
