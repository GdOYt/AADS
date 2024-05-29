contract casinoProxy is casinoBank {
	mapping(address => bool) public authorized;
	address[] public casinoGames;
	mapping(address => uint) public count;
	modifier onlyAuthorized {
		require(authorized[msg.sender]);
		_;
	}
	modifier onlyCasinoGames {
		bool isCasino;
		for (uint i = 0; i < casinoGames.length; i++) {
			if (msg.sender == casinoGames[i]) {
				isCasino = true;
				break;
			}
		}
		require(isCasino);
		_;
	}
	function casinoProxy(address authorizedAddress, address blackjackAddress, address tokenContract) casinoBank(tokenContract) public {
		authorized[authorizedAddress] = true;
		casinoGames.push(blackjackAddress);
	}
	function shift(address receiver, uint numTokens) public onlyCasinoGames {
		balanceOf[receiver] = safeAdd(balanceOf[receiver], numTokens);
		playerBalance = safeAdd(playerBalance, numTokens);
	}
	function withdrawFor(address receiver, uint amount, uint8 v, bytes32 r, bytes32 s) public onlyAuthorized keepAlive {
		uint gasCost = msg.gas / 1000 * gasPrice;
		var player = ecrecover(keccak256(receiver, amount, count[receiver]), v, r, s);
		count[receiver]++;
		uint value = safeAdd(safeMul(amount, 10000), gasCost);
		balanceOf[player] = safeSub(balanceOf[player], value);
		playerBalance = safeSub(playerBalance, value);
		assert(edg.transfer(receiver, amount));
		Withdrawal(player, receiver, amount);
	}
	function setGameAddress(uint8 game, address newAddress) public onlyOwner {
		if (game < casinoGames.length) casinoGames[game] = newAddress;
		else casinoGames.push(newAddress);
	}
	function authorize(address addr) public onlyOwner {
		authorized[addr] = true;
	}
	function deauthorize(address addr) public onlyOwner {
		authorized[addr] = false;
	}
	function setGasPrice(uint8 price) public onlyOwner {
		gasPrice = price;
	}
	function move(uint8 game, uint value, bytes data, uint8 v, bytes32 r, bytes32 s) public onlyAuthorized isAlive {
		require(game < casinoGames.length);
		require(safeMul(bankroll(), 10000) > value * 8);  
		var player = ecrecover(keccak256(data), v, r, s);
		require(withdrawAfter[player] == 0 || now < withdrawAfter[player]);
		value = safeAdd(value, msg.gas / 1000 * gasPrice);
		balanceOf[player] = safeSub(balanceOf[player], value);
		playerBalance = safeSub(playerBalance, value);
		assert(casinoGames[game].call(data));
	}
}
