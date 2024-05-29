contract JOYToken is Pausable, ERC827Token {
    string public constant name = "BLOCK JOY";
    string public constant symbol = "JOY";
    uint256 public constant decimals = 18;
    uint256 public constant exchangeRatio = 10000;
    uint256 public constant sellCut = 1000;
    uint256 public incomeFees;
    address public cfoAddress;
    event Buy(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event Sell(address indexed seller, uint256 tokenAmount, uint256 ethAmount);
    function JOYToken() public {
        cfoAddress = msg.sender;
    }
    function sell(uint256 _tokenCount) external {
        require(_tokenCount > 0);
        require(_tokenCount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_tokenCount);
        totalSupply_ = totalSupply_.sub(_tokenCount);
        Transfer(msg.sender, 0x0, _tokenCount);
        uint256 value = _tokenCount.div(exchangeRatio);
        uint256 cut = value.div(sellCut);
        value = value.sub(cut);
        Sell(msg.sender, _tokenCount, value);
        if (cut > 0) {
            incomeFees = incomeFees.add(cut);
        }
        if (value > 0) {
            msg.sender.transfer(value);
        }
    }
    function setCFO(address _newCFO) external onlyOwner {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    function withdrawFees(uint256 _value) external onlyCFO {
        require(_value <= incomeFees);
        incomeFees = incomeFees.sub(_value);
        cfoAddress.transfer(_value);
    }
    function() external payable whenNotPaused {
        require(msg.value > 0);
        uint256 _count = msg.value;
        uint256 tokenCount = _count.mul(exchangeRatio);
        totalSupply_ = totalSupply_.add(tokenCount);
        balances[msg.sender] = balances[msg.sender].add(tokenCount);
        Buy(msg.sender, _count, tokenCount);
        Transfer(0x0, msg.sender, tokenCount);
    }
}
