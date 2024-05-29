contract gsToken is OwnableToken, BurnableToken, StandardToken {
	string public name;
	string public symbol;
	uint8 public decimals;
	bool public paused = true;
	mapping(address => bool) public whitelist;
	modifier whenNotPaused() {
		require(!paused || whitelist[msg.sender]);
		_;
	}
	constructor(string _name,string _symbol,uint8 _decimals, address holder, address buffer) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		Transfer(address(0), holder, balances[holder] = totalSupply_ = uint256(10)**(9 + decimals));
		addToWhitelist(holder);
		addToWhitelist(buffer);
	}
	function unpause() public onlyOwner {
		paused = false;
	}
	function pause() public onlyOwner {
		paused = true;
	}
	function addToWhitelist(address addr) public onlyOwner {
		whitelist[addr] = true;
	}
	function removeFromWhitelist(address addr) public onlyOwner {
		whitelist[addr] = false;
	}
	function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
		return super.transfer(to, value);
	}
	function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
		return super.transferFrom(from, to, value);
	}
}
