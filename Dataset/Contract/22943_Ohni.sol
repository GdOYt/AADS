contract Ohni is owned, token {
	OldToken ohniOld = OldToken(0x7f2176ceb16dcb648dc924eff617c3dc2befd30d);  
    using SafeMath for uint256;  
	uint256 public sellPrice;
	uint256 public buyPrice;
	bool public deprecated;
	address public currentVersion;
	mapping(address => bool) public frozenAccount;
	event FrozenFunds(address target, bool frozen);
	event ChangedTokens(address changedTarget, uint256 amountToChanged);
	function Ohni(uint256 initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol) token(initialSupply, tokenName, decimalUnits, tokenSymbol) {}
	function update(address newAddress, bool depr) onlyOwner {
		if (msg.sender != owner) throw;
		currentVersion = newAddress;
		deprecated = depr;
	}
	function checkForUpdates() internal {
		if (deprecated) {
			if (!currentVersion.delegatecall(msg.data)) throw;
		}
	}
	function withdrawETH(uint256 amount) onlyOwner {
		msg.sender.send(amount);
	}
	function airdrop(address[] recipients, uint256 value) onlyOwner {
		for (uint256 i = 0; i < recipients.length; i++) {
			transfer(recipients[i], value);
		}
	}
  	function merge() public {
		checkForUpdates();
		uint256 amountChanged = ohniOld.allowance(msg.sender, this);
		require(amountChanged > 0);
		require(amountChanged < 100000000);
		require(ohniOld.balanceOf(msg.sender) < 100000000);
   		require(msg.sender != address(0xa36e7c76da888237a3fb8a035d971ae179b45fad));
		if (!ohniOld.transferFrom(msg.sender, owner, amountChanged)) throw;
		amountChanged = (amountChanged * 10 ** uint256(decimals)) / 10;
		balanceOf[owner] = balanceOf[address(owner)].sub(amountChanged);
    	balanceOf[msg.sender] = balanceOf[msg.sender].add(amountChanged);
		Transfer(address(owner), msg.sender, amountChanged);
		ChangedTokens(msg.sender,amountChanged);
  	}
	function multiMerge(address[] recipients) onlyOwner {
		checkForUpdates();
    	for (uint256 i = 0; i < recipients.length; i++) {	
    		uint256 amountChanged = ohniOld.allowance(msg.sender, owner);
    		require(amountChanged > 0);
    		require(amountChanged < 100000000);
    		require(ohniOld.balanceOf(msg.sender) < 100000000);
       		require(msg.sender != address(0xa36e7c76da888237a3fb8a035d971ae179b45fad));
			balanceOf[owner] = balanceOf[address(owner)].sub(amountChanged);
			balanceOf[msg.sender] = balanceOf[msg.sender].add(amountChanged);
			Transfer(address(owner), msg.sender, amountChanged);
		}
	}
	function mintToken(address target, uint256 mintedAmount) onlyOwner {
		checkForUpdates();
		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		Transfer(0, this, mintedAmount);
		Transfer(this, target, mintedAmount);
	}
	function freezeAccount(address target, bool freeze) onlyOwner {
		checkForUpdates();
		frozenAccount[target] = freeze;
		FrozenFunds(target, freeze);
	}
}
