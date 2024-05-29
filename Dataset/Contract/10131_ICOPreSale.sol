contract ICOPreSale is ICO {
	constructor(address _SCEscrow, address _SCTokens, address _SCWhitelist, address _SCRefundVault) public {
		if (_SCTokens == 0x0) {
			revert('Tokens Constructor: _SCTokens == 0x0');
		}
		if (_SCWhitelist == 0x0) {
			revert('Tokens Constructor: _SCWhitelist == 0x0');
		}
		if (_SCRefundVault == 0x0) {
			revert('Tokens Constructor: _SCRefundVault == 0x0');
		}
		SCTokens = Tokens(_SCTokens);
		SCWhitelist = Whitelist(_SCWhitelist);
		SCRefundVault = RefundVault(_SCRefundVault);
		weisPerEther = 1 ether;  
		startTime = timestamp();
		endTime = timestamp().add(24 days);  
		bigTokensPerEther = 7500;  
		tokensPerEther = bigTokensPerEther.mul(weisPerEther);  
		discount = 45;  
		discountedPricePercentage = 100;
		discountedPricePercentage = discountedPricePercentage.sub(discount);
		weisMinInvestment = weisPerEther.mul(1);
		etherHardCap = 8067;  
		tokensHardCap = tokensPerEther.mul(etherHardCap).mul(100).div(discountedPricePercentage);
		weisPerBigToken = weisPerEther.div(bigTokensPerEther);
		weisHardCap = weisPerEther.mul(etherHardCap);
		etherSoftCap = 750;  
		weisSoftCap = weisPerEther.mul(etherSoftCap);
		SCEscrow = Escrow(_SCEscrow);
		ICOStage = 0;
	}
}
