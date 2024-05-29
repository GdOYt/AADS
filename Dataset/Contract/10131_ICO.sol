contract ICO is HardcodedWallets, Haltable {
	Tokens public SCTokens;	 
	RefundVault public SCRefundVault;	 
	Whitelist public SCWhitelist;	 
	Escrow public SCEscrow;  
	uint256 public startTime;
	uint256 public endTime;
	bool public isFinalized = false;
	uint256 public weisPerBigToken;  
	uint256 public weisPerEther;
	uint256 public tokensPerEther;  
	uint256 public bigTokensPerEther;  
	uint256 public weisRaised;  
	uint256 public etherHardCap;  
	uint256 public tokensHardCap;  
	uint256 public weisHardCap;  
	uint256 public weisMinInvestment;  
	uint256 public etherSoftCap;  
	uint256 public tokensSoftCap;  
	uint256 public weisSoftCap;  
	uint256 public discount;  
	uint256 discountedPricePercentage;
	uint8 ICOStage;
	function () payable public {
		buyTokens();
	}
	function buyTokens() public stopInEmergency payable returns (bool) {
		if (msg.value == 0) {
			error('buyTokens: ZeroPurchase');
			return false;
		}
		uint256 tokenAmount = buyTokensLowLevel(msg.sender, msg.value);
		if (!SCRefundVault.deposit.value(msg.value)(msg.sender, tokenAmount)) {
			revert('buyTokens: unable to transfer collected funds from ICO contract to Refund Vault');  
		}
		emit BuyTokens(msg.sender, msg.value, tokenAmount);  
		return true;
	}
	function buyTokensLowLevel(address _beneficiary, uint256 _weisAmount) private stopInEmergency returns (uint256 tokenAmount) {
		if (_beneficiary == 0x0) {
			revert('buyTokensLowLevel: _beneficiary == 0x0');  
		}
		if (timestamp() < startTime || timestamp() > endTime) {
			revert('buyTokensLowLevel: Not withinPeriod');  
		}
		if (!SCWhitelist.isInvestor(_beneficiary)) {
			revert('buyTokensLowLevel: Investor is not registered on the whitelist');  
		}
		if (isFinalized) {
			revert('buyTokensLowLevel: ICO is already finalized');  
		}
		if (_weisAmount < weisMinInvestment) {
			revert('buyTokensLowLevel: Minimal investment not reached. Not enough ethers to perform the minimal purchase');  
		}
		if (weisRaised.add(_weisAmount) > weisHardCap) {
			revert('buyTokensLowLevel: HardCap reached. Not enough tokens on ICO contract to perform this purchase');  
		}
		tokenAmount = _weisAmount.mul(weisPerEther).div(weisPerBigToken);
		tokenAmount = tokenAmount.mul(100).div(discountedPricePercentage);
		weisRaised = weisRaised.add(_weisAmount);
		if (!SCTokens.transfer(_beneficiary, tokenAmount)) {
			revert('buyTokensLowLevel: unable to transfer tokens from ICO contract to beneficiary');  
		}
		emit BuyTokensLowLevel(msg.sender, _beneficiary, _weisAmount, tokenAmount);  
		return tokenAmount;
	}
	function updateEndTime(uint256 _endTime) onlyOwner public returns (bool) {
		endTime = _endTime;
		emit UpdateEndTime(_endTime);  
	}
	function finalize(bool _forceRefund) onlyOwner public returns (bool) {
		if (isFinalized) {
			error('finalize: ICO is already finalized.');
			return false;
		}
		if (weisRaised >= weisSoftCap && !_forceRefund) {
			if (!SCRefundVault.close()) {
				error('finalize: SCRefundVault.close() failed');
				return false;
			}
		} else {
			if (!SCRefundVault.enableRefunds()) {
				error('finalize: SCRefundVault.enableRefunds() failed');
				return false;
			}
			if(_forceRefund) {
				emit ForceRefund();  
			}
		}
		uint256 balanceAmount = SCTokens.balanceOf(this);
		if (!SCTokens.transfer(address(SCEscrow), balanceAmount)) {
			error('finalize: unable to return remaining ICO tokens');
			return false;
		}
		if(!SCEscrow.deposit(balanceAmount)) {
			error('finalize: unable to return remaining ICO tokens');
			return false;
		}
		isFinalized = true;
		emit Finalized();  
		return true;
	}
	function claimRefund() public stopInEmergency returns (bool) {
		if (!isFinalized) {
			error('claimRefund: ICO is not yet finalized.');
			return false;
		}
		if (!SCRefundVault.isRefunding()) {
			error('claimRefund: RefundVault state != State.Refunding');
			return false;
		}
		uint256 tokenAmount = SCRefundVault.getTokensAcquired(msg.sender);
		emit GetBackTokensOnRefund(msg.sender, this, tokenAmount);  
		if (!SCTokens.refundTokens(msg.sender, tokenAmount)) {
			error('claimRefund: unable to transfer investor tokens to ICO contract before refunding');
			return false;
		}
		if (!SCRefundVault.refund(msg.sender)) {
			error('claimRefund: SCRefundVault.refund() failed');
			return false;
		}
		return true;
	}
	function fundICO() public onlyOwner {
		if (!SCEscrow.fundICO(tokensHardCap, ICOStage)) {
			revert('ICO funding failed');
		}
	}
	event BuyTokens(address indexed _purchaser, uint256 _value, uint256 _amount);
	event BuyTokensOraclePayIn(address indexed _purchaser, address indexed _beneficiary, uint256 _weisAmount, uint256 _tokenAmount);
	event BuyTokensLowLevel(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount);
	event Finalized();
	event ForceRefund();
	event GetBackTokensOnRefund(address _from, address _to, uint256 _amount);
	event UpdateEndTime(uint256 _endTime);
}
