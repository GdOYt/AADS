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
        buy(_referrer);
    }
    function() public payable {}
    function buy(address _referrer)
        public
        payable
        onlyOwner
    {
        p3dContract.buy.value(msg.value)(_referrer);
    }
    function withdraw()
        external
        onlyOwner
    {
        p3dContract.withdraw();
        owner.transfer(address(this).balance);
    }
}
