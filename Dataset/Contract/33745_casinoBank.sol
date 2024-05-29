contract casinoBank is owned, safeMath{
	uint public playerBalance;
  mapping(address=>uint) public balanceOf;
	mapping(address=>uint) public withdrawAfter;
	uint public gasPrice = 20;
	token edg;
	uint public closeAt;
	event Deposit(address _player, uint _numTokens, bool _chargeGas);
	event Withdrawal(address _player, address _receiver, uint _numTokens);
	function casinoBank(address tokenContract) public{
		edg = token(tokenContract);
	}
	function deposit(address receiver, uint numTokens, bool chargeGas) public isAlive{
		require(numTokens > 0);
		uint value = safeMul(numTokens,10000); 
		if(chargeGas) value = safeSub(value, msg.gas/1000 * gasPrice);
		assert(edg.transferFrom(msg.sender, address(this), numTokens));
		balanceOf[receiver] = safeAdd(balanceOf[receiver], value);
		playerBalance = safeAdd(playerBalance, value);
		Deposit(receiver, numTokens, chargeGas);
  }
	function requestWithdrawal() public{
		withdrawAfter[msg.sender] = now + 7 minutes;
	}
	function cancelWithdrawalRequest() public{
		withdrawAfter[msg.sender] = 0;
	}
	function withdraw(uint amount) public keepAlive{
		require(withdrawAfter[msg.sender]>0 && now>withdrawAfter[msg.sender]);
		withdrawAfter[msg.sender] = 0;
		uint value = safeMul(amount,10000);
		balanceOf[msg.sender]=safeSub(balanceOf[msg.sender],value);
		playerBalance = safeSub(playerBalance, value);
		assert(edg.transfer(msg.sender, amount));
		Withdrawal(msg.sender, msg.sender, amount);
	}
	function withdrawBankroll(uint numTokens) public onlyOwner {
		require(numTokens <= bankroll());
		assert(edg.transfer(owner, numTokens));
	}
	function bankroll() constant public returns(uint){
		return safeSub(edg.balanceOf(address(this)), playerBalance/10000);
	}
  function close() onlyOwner public{
		if(playerBalance == 0) selfdestruct(owner);
		if(closeAt == 0) closeAt = now + 30 days;
		else if(closeAt < now) selfdestruct(owner);
  }
	function open() onlyOwner public{
		closeAt = 0;
	}
	modifier isAlive {
		require(closeAt == 0);
		_;
	}
	modifier keepAlive {
		if(closeAt > 0) closeAt = now + 30 days;
		_;
	}
}
