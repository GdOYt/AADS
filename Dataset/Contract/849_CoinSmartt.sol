contract CoinSmartt is Superuser, PausableToken, CappedToken {
	string public name = "CoinSmartt";
	string public symbol = "TURN";
	uint256 public decimals = 18;
	string public constant ROLE_MINTER = "minter";
	constructor(address _minter) CappedToken(7663809523810000000000000000) {
		addRole(_minter, ROLE_MINTER);
	}
	function mint(
		address _to,
		uint256 _amount
		)
		onlyRole("minter")
		canMint
		public
		returns (bool)
	{
		require(totalSupply_.add(_amount) <= cap);
		totalSupply_ = totalSupply_.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Mint(_to, _amount);
		emit Transfer(address(0), _to, _amount);
		return true;
	}
	function removeMinter(address _minter) onlyOwnerOrSuperuser {
		removeRole(_minter, "minter");
	}
	function addMinter(address _minter) onlyOwnerOrSuperuser {
		addRole(_minter, "minter");
	}
}
