contract LATOPreICO {
    LATPToken public latpToken = LATPToken(0x12826eACF16678A6Ab9772fB0751bca32F1F0F53);
    address public founder;
    uint256 public baseTokenPrice = 3 szabo;  
    mapping (address => uint) public investments;
    event LATPTransaction(uint256 indexed transactionId, uint256 transactionValue, uint256 indexed timestamp);
    modifier onlyFounder() {
        if (msg.sender != founder) {
            throw;
        }
        _;
    }
    modifier minInvestment() {
        if (msg.value < baseTokenPrice) {
            throw;
        }
        _;
    }
    function fund()
        public
        minInvestment
        payable
        returns (uint)
    {
        uint tokenCount = msg.value / baseTokenPrice;
        uint investment = tokenCount * baseTokenPrice;
        if (msg.value > investment && !msg.sender.send(msg.value - investment)) {
            throw;
        }
        investments[msg.sender] += investment;
        if (!founder.send(investment)) {
            throw;
        }
        uint transactionId = 0;
        for (uint i = 0; i < 32; i++) {
            uint b = uint(msg.data[35 - i]);
            transactionId += b * 256**i;
        }
        LATPTransaction(transactionId, investment, now);
        return tokenCount;
    }
    function fundManually(address beneficiary, uint _tokenCount)
        external
        onlyFounder
        returns (uint)
    {
        uint investment = _tokenCount * baseTokenPrice;
        investments[beneficiary] += investment;
        if (!latpToken.issueTokens(beneficiary, _tokenCount)) {
            throw;
        }
        return _tokenCount;
    }
    function setTokenAddress(address _newTokenAddress)
        external
        onlyFounder
        returns (bool)
    {
        latpToken = LATPToken(_newTokenAddress);
        return true;
    }
    function changeBaseTokenPrice(uint valueInWei)
        external
        onlyFounder
        returns (bool)
    {
        baseTokenPrice = valueInWei;
        return true;
    }
    function LATOPreICO() {
        founder = msg.sender;
    }
    function () payable {
        fund();
    }
}
