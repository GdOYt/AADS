contract casinoProxy is casinoBank{
  mapping(address => bool) public authorized;
  mapping(address => mapping(address => bool)) public authorizedByUser;
  mapping(address => mapping(address => uint8)) public lockedByUser;
  address[] public casinoGames;
	mapping(address => uint) public count;
	modifier onlyAuthorized {
    require(authorized[msg.sender]);
    _;
  }
	modifier onlyCasinoGames {
		bool isCasino;
		for (uint i = 0; i < casinoGames.length; i++){
			if(msg.sender == casinoGames[i]){
				isCasino = true;
				break;
			}
		}
		require(isCasino);
		_;
	}
  function casinoProxy(address authorizedAddress, address blackjackAddress, address tokenContract) casinoBank(tokenContract) public{
    authorized[authorizedAddress] = true;
    casinoGames.push(blackjackAddress);
  }
	function shift(address player, uint numTokens, bool isReceiver) public onlyCasinoGames{
		require(authorizedByUser[player][msg.sender]);
		var gasCost = msg.gas/1000 * gasPrice; 
		if(isReceiver){
			numTokens = safeSub(numTokens, gasCost);
			balanceOf[player] = safeAdd(balanceOf[player], numTokens);
			playerBalance = safeAdd(playerBalance, numTokens);
		}
		else{
			numTokens = safeAdd(numTokens, gasCost);
			balanceOf[player] = safeSub(balanceOf[player], numTokens);
			playerBalance = safeSub(playerBalance, numTokens);
		}
	}
  function withdrawFor(address receiver, uint amount, uint8 v, bytes32 r, bytes32 s) public onlyAuthorized keepAlive{
		uint gasCost =  msg.gas/1000 * gasPrice;
		var player = ecrecover(keccak256(receiver, amount, count[receiver]), v, r, s);
		count[receiver]++;
		uint value = safeAdd(safeMul(amount,10000), gasCost);
    balanceOf[player] = safeSub(balanceOf[player], value);
		playerBalance = safeSub(playerBalance, value);
    assert(edg.transfer(receiver, amount));
		Withdrawal(player, receiver, amount);
  }
  function setGameAddress(uint8 game, address newAddress) public onlyOwner{
    if(game<casinoGames.length) casinoGames[game] = newAddress;
    else casinoGames.push(newAddress);
  }
  function authorize(address addr) public onlyOwner{
    authorized[addr] = true;
  }
  function deauthorize(address addr) public onlyOwner{
    authorized[addr] = false;
  }
  function authorizeCasino(address playerAddress, address casinoAddress, uint8 v, bytes32 r, bytes32 s) public{
  	address player = ecrecover(keccak256(casinoAddress,lockedByUser[playerAddress][casinoAddress],true), v, r, s);
  	require(player == playerAddress);
  	authorizedByUser[player][casinoAddress] = true;
  }
  function deauthorizeCasino(address playerAddress, address casinoAddress, uint8 v, bytes32 r, bytes32 s) public{
  	address player = ecrecover(keccak256(casinoAddress,lockedByUser[playerAddress][casinoAddress],false), v, r, s);
  	require(player == playerAddress);
  	authorizedByUser[player][casinoAddress] = false;
  	lockedByUser[player][casinoAddress]++; 
  }
	function setGasPrice(uint8 price) public onlyOwner{
		gasPrice = price;
	}
  function move(uint8 game, bytes data, uint8 v, bytes32 r, bytes32 s) public onlyAuthorized isAlive{
    require(game < casinoGames.length);
    var player = ecrecover(keccak256(data), v, r, s);
		require(withdrawAfter[player] == 0 || now<withdrawAfter[player]);
		assert(checkAddress(player, data));
    assert(casinoGames[game].call(data));
  }
  function checkAddress(address player, bytes data) constant internal returns(bool){
  	bytes memory ba;
  	assembly {
      let m := mload(0x40)
      mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, player))
      mstore(0x40, add(m, 52))
      ba := m
   }
   for(uint8 i = 0; i < 20; i++){
   	if(data[16+i]!=ba[i]) return false;
   }
   return true;
  }
}
