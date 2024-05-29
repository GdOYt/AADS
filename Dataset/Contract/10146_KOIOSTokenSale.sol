contract KOIOSTokenSale is Ownable {
	using SafeMath for uint256;
	KOIOSToken public token;
	uint256 public startingTimestamp = 1518696000;
	uint256 public endingTimestamp = 1521115200;
	uint256 public tokenPriceInEth = 0.0001 ether;
	uint256 public tokensForSale = 400000000 * 1E5;
	uint256 public totalTokenSold;
	uint256 public totalEtherRaised;
	mapping(address => uint256) public etherRaisedPerWallet;
	address public wallet;
	bool internal isClose = false;
	event WalletChange(address _wallet, uint256 _timestamp);
	event TokenPurchase(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount, uint256 _timestamp);
	event TransferManual(address indexed _from, address indexed _to, uint256 _value, string _message);
	function KOIOSTokenSale(address _token, uint256 _startingTimestamp, uint256 _endingTimestamp, uint256 _tokensPerEth, uint256 _tokensForSale, address _wallet) public {
		token = KOIOSToken(_token);
		startingTimestamp = _startingTimestamp;
		endingTimestamp = _endingTimestamp;
		tokenPriceInEth =  1E18 / _tokensPerEth;  
		tokensForSale = _tokensForSale;
		wallet = _wallet;
	}
	function isValidPurchase(uint256 value, uint256 amount) internal constant returns (bool) {
		bool validTimestamp = startingTimestamp <= block.timestamp && endingTimestamp >= block.timestamp;
		bool validValue = value != 0;
		bool validRate = tokenPriceInEth > 0;
		bool validAmount = tokensForSale.sub(totalTokenSold) >= amount && amount > 0;
		return validTimestamp && validValue && validRate && validAmount && !isClose;
	}
	function calculate(uint256 value) public constant returns (uint256) {
		uint256 tokenDecimals = token.decimals();
		uint256 tokens = value.mul(10 ** tokenDecimals).div(tokenPriceInEth);
		return tokens;
	}
	function() public payable {
		buyTokens(msg.sender);
	}
	function buyTokens(address beneficiary) public payable {
		require(beneficiary != address(0));
		uint256 value = msg.value;
		uint256 tokens = calculate(value);
		require(isValidPurchase(value , tokens));
		totalTokenSold = totalTokenSold.add(tokens);
		totalEtherRaised = totalEtherRaised.add(value);
		etherRaisedPerWallet[msg.sender] = etherRaisedPerWallet[msg.sender].add(value);
		token.transfer(beneficiary, tokens);
		TokenPurchase(msg.sender, beneficiary, value, tokens, now);
	}
	function transferManual(address _to, uint256 _value, string _message) onlyOwner public returns (bool) {
		require(_to != address(0));
		token.transfer(_to , _value);
		TransferManual(msg.sender, _to, _value, _message);
		return true;
	}
	function setWallet(address _wallet) onlyOwner public returns(bool) {
		wallet = _wallet;
		WalletChange(_wallet , now);
		return true;
	}
	function withdraw() onlyOwner public {
		wallet.transfer(this.balance);
	}
	function close() onlyOwner public {
		uint256 tokens = token.balanceOf(this); 
		token.transfer(owner , tokens);
		withdraw();
		isClose = true;
	}
}
