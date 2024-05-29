contract JcnxxxCrowdsale is FinalizableCrowdsale, MintedCrowdsale, CappedCrowdsale {
	uint256 public constant FOUNDERS_SHARE = 30000000 * (10 ** uint256(18));	 
	uint256 public constant RESERVE_FUND = 15000000 * (10 ** uint256(18));		 
	uint256 public constant CONTENT_FUND = 5000000 * (10 ** uint256(18));		 
	uint256 public constant BOUNTY_FUND = 5000000 * (10 ** uint256(18));		 
	uint256 public constant HARD_CAP = 100000000 * (10 ** uint256(18));			 
	enum IcoPhases { PrivateSale, EarlyBirdPresale, Presale, EarlyBirdCrowdsale, FullCrowdsale }
	struct Phase {
		uint256 startTime;
		uint256 endTime;
		uint256 minimum;	 
		uint8 bonus;
	}
	mapping (uint => Phase) ico;
	function JcnxxxCrowdsale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, MintableToken _token) public
	CappedCrowdsale(HARD_CAP.div(_rate))
	FinalizableCrowdsale()
	MintedCrowdsale()
	TimedCrowdsale(_openingTime, _closingTime)
	Crowdsale(_rate, _wallet, _token) 
	{       
		ico[uint(IcoPhases.PrivateSale)] = Phase(1531126800, 1537001999, 10000000000000000000, 50);	
		ico[uint(IcoPhases.EarlyBirdPresale)] = Phase(1537002000, 1537865999, 750000000000000000, 25);	
		ico[uint(IcoPhases.Presale)] = Phase(1537866000, 1538729999, 500000000000000000, 15);
		ico[uint(IcoPhases.EarlyBirdCrowdsale)] = Phase(1538730000, 1539593999, 250000000000000000, 5);
		ico[uint(IcoPhases.FullCrowdsale)] = Phase(1539594000, 1542275999, 1000000000000000, 2);
	}
	function mintReservedTokens() onlyOwner public {
		uint256 reserved_tokens = FOUNDERS_SHARE.add(RESERVE_FUND).add(CONTENT_FUND).add(BOUNTY_FUND);
		require(MintableToken(token).mint(wallet, reserved_tokens));
	}
	function airdrop(address[] _to, uint256[] _value) onlyOwner public returns (bool) {
		require(!isFinalized);
		require(_to.length == _value.length);
        require(_to.length <= 100);
        for(uint8 i = 0; i < _to.length; i++) {
            require(MintableToken(token).mint(_to[i], (_value[i].mul((10 ** uint256(18))))) == true);
        }
        return true;
	}
	function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
		super._preValidatePurchase(_beneficiary, _weiAmount);
		uint256 minimum = _currentIcoPhaseMinimum();
		require(_weiAmount >= minimum);
	}
	function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
		uint256 tokens = _weiAmount.mul(rate);
		uint bonus = _currentIcoPhaseBonus();
		return tokens.add((tokens.mul(bonus)).div(100));
	}
	function finalization() internal {
		uint256 _tokenAmount = HARD_CAP.sub(token.totalSupply());
		require(MintableToken(token).mint(wallet, _tokenAmount));
		super.finalization();
	}
	function _currentIcoPhaseBonus() public view returns (uint8) {
		for (uint i = 0; i < 5; i++) {
			if(ico[i].startTime <= now && ico[i].endTime >= now){
				return ico[i].bonus;
			}
		}
		return 0;	 
	}
	function _currentIcoPhaseMinimum() public view returns (uint256) {
		for (uint i = 0; i < 5; i++) {
			if(ico[i].startTime <= now && ico[i].endTime >= now){
				return ico[i].minimum;
			}
		}
		return 0;	 
	}
}
