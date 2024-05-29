contract ArtMuseumV1 is ArtMuseumBase, usingOraclize {
	using strings for *;
	uint32 public lastcombo;
	uint public lastStealBlockNumber;
	uint8[] public oldestExtraStealProbability;
	string randomQuery;
	string queryType;
	uint public nextStealTimestamp;
	uint32 public oraclizeGas;
	uint32 public oraclizeGasExtraArtwork;
	uint32 public etherExchangeLikeCoin;
	bytes32 nextStealId;
	uint8 public numOfTimesSteal;
	uint public oraclizeFee;
	event newPurchase(address player, uint32 startId, uint8[] artworkTypes, uint32[] startSequenceNumbers);
	event newSteal(uint timestamp,uint32[] stolenArtworks,uint8[] artworkTypes,uint32[] sequenceNumbers, uint256[] values,address[] players);
	event newStealRewards(uint128 total,uint128[] values);
	event newSell(uint32[] artworkId, address player, uint256 value);
	event newTriggerOraclize(bytes32 nextStealId, uint waittime, uint gasAmount, uint price, uint balancebefore, uint balance);
	event newOraclizeCallback(bytes32 nextStealId, string result, uint32 killed, uint128 killedValue, uint128 distValue,uint oraclizeFee,uint gaslimit,uint exchange);
	function initOraclize() public onlyOwner {
		if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
			oraclize_setNetwork();
	}
	function init1() public onlyOwner {
		randomQuery = "10 random numbers between 1 and 100000";
		queryType = "WolframAlpha";
		oraclizeGas = 150000;
		oraclizeGasExtraArtwork = 14000;
		etherExchangeLikeCoin = 50000;
		oldestExtraStealProbability = [3,5,10,15,30,50];
		numOfTimesSteal = 1;
	}
	function giveArtworks(uint8[] artworkTypes, address receiver, uint256 _value) internal {
		uint32 len = uint32(artworkTypes.length);
		require(numArtworks + len < maxArtworks);
		uint256 amount = 0;
		for (uint16 i = 0; i < len; i++) {
			require(artworkTypes[i] < costs.length);
			amount += costs[artworkTypes[i]];
		}
		require(_value >= amount);
		uint8 artworkType;
		uint32[] memory seqnolist = new uint32[](len);
		for (uint16 j = 0; j < len; j++) {
			if (numArtworks < ids.length)
				ids[numArtworks] = lastId;
			else
				ids.push(lastId);
			artworkType = artworkTypes[j];
			userArtworkSequenceNumber[receiver][artworkType]++;
			seqnolist[j] = userArtworkSequenceNumber[receiver][artworkType];
			artworks[lastId] = Artwork(artworkTypes[j], userArtworkSequenceNumber[receiver][artworkType], values[artworkType], receiver);
			numArtworks++;
			lastId++;
			numArtworksXType[artworkType]++;
		}
		emit newPurchase(receiver, lastId - len, artworkTypes, seqnolist);
	}
	function replaceArtwork(uint16 index) internal {
		uint32 artworkId = ids[index];
		numArtworksXType[artworks[artworkId].artworkType]--;
		numArtworks--;
		if (artworkId == oldest) oldest = 0;
		delete artworks[artworkId];
		if (numArtworks>0)
			ids[index] = ids[numArtworks];
		delete ids[numArtworks];
		ids.length = numArtworks;
	}
	function getOldest() public constant returns(uint32 artworkId,uint8 artworkType, uint32 sequenceNumber, uint128 value, address player) {
		if (numArtworks==0) artworkId = 0;
		else {
			artworkId = oldest;
			if (artworkId==0) {
				artworkId = ids[0];
				for (uint16 i = 1; i < numArtworks; i++) {
					if (ids[i] < artworkId)  
						artworkId = ids[i];
				}
			}
			artworkType = artworks[artworkId].artworkType;
			sequenceNumber = artworks[artworkId].sequenceNumber;
			value = artworks[artworkId].value;
			player = artworks[artworkId].player;
		}
	}
	function setOldest() internal returns(uint32 artworkId,uint16 index) {
		if (numArtworks==0) artworkId = 0;
		else {
			if (oldest==0) {
				oldest = ids[0];
				index = 0;
				for (uint16 i = 1; i < numArtworks; i++) {
					if (ids[i] < oldest) {  
						oldest = ids[i];
						index = i;
					}
				}
			} else {
				for (uint16 j = 0; j < numArtworks; j++) {
					if (ids[j] == oldest) {
						index = j;
						break;
					}
				}				
			}
			artworkId = oldest;
		}
	}
	function sellArtwork(uint32 artworkId) public {
		require(msg.sender == artworks[artworkId].player);
		uint256 val = uint256(artworks[artworkId].value); 
		uint16 artworkIndex;
		bool found = false;
		for (uint16 i = 0; i < numArtworks; i++) {
			if (ids[i] == artworkId) {
				artworkIndex = i;
				found = true;
				break;
			}
		}
		require(found == true);
		replaceArtwork(artworkIndex);
		if (val>0)
			like.transfer(msg.sender,val);
		uint32[] memory artworkIds = new uint32[](1);
		artworkIds[0] = artworkId;
		emit newSell(artworkIds, msg.sender, val);
	}
	function triggerStealManually(uint32 inseconds) public payable ownerOrOperator {
		require((nextStealTimestamp) < now);  
		triggerSteal(inseconds, (oraclizeGas + oraclizeGasExtraArtwork * numArtworks));
	}
	function triggerStealManually2(string result) public payable ownerOrOperator {
		uint gaslimit = gasleft();
		oraclizeFee = (gaslimit) * tx.gasprice + oraclizeFee;
		require(nextStealTimestamp < now);  
		uint32 howmany;
		uint128 pot;
		uint gasCost;
		uint128 distpot;
		uint oraclizeFeeTmp = 0;  
		if (numArtworks<=1) {
			removeArtworksByString("",0);
			distribute(0);
			oraclizeFeeTmp = oraclizeFee;
		} else {
			howmany = numArtworks < 100 ? (numArtworks < 10 ? (numArtworks < 2 ? 0 : 1) : numArtworks / 10) : 10;  
			pot = removeArtworksByString(result,howmany);
			gasCost = ((oraclizeFee * etherExchangeLikeCoin) / 1 ether) * 1 ether;
			if (pot > gasCost)
				distpot = uint128(pot - gasCost);
			distribute(distpot);  
			oraclizeFeeTmp = oraclizeFee;
			oraclizeFee = 0;
		}
		emit newOraclizeCallback(0x0,result,howmany,pot,distpot,oraclizeFeeTmp,gaslimit,etherExchangeLikeCoin);
	}
	function triggerStealManually3(string result,uint gaslimit) public payable ownerOrOperator {
		oraclizeFee = (gaslimit) * tx.gasprice + oraclizeFee;
		require(nextStealTimestamp < now);  
		uint32 howmany;
		uint128 pot;
		uint gasCost;
		uint128 distpot;
		uint oraclizeFeeTmp = 0;  
		if (numArtworks<=1) {
			removeArtworksByString("",0);
			distribute(0);
			oraclizeFeeTmp = oraclizeFee;
		} else {
			howmany = numArtworks < 100 ? (numArtworks < 10 ? (numArtworks < 2 ? 0 : 1) : numArtworks / 10) : 10;  
			pot = removeArtworksByString(result,howmany);
			gasCost = ((oraclizeFee * etherExchangeLikeCoin) / 1 ether) * 1 ether;
			if (pot > gasCost)
				distpot = uint128(pot - gasCost);
			distribute(distpot);  
			oraclizeFeeTmp = oraclizeFee;
			oraclizeFee = 0;
		}
		emit newOraclizeCallback(0x0,result,howmany,pot,distpot,oraclizeFeeTmp,gaslimit,etherExchangeLikeCoin);
	}
	function timeTillNextSteal() constant internal returns(uint32) {
		return (86400 / (1 + numArtworks / 100)) / ( numOfTimesSteal );
	}
	function triggerSteal(uint32 inseconds, uint gasAmount) internal {
		uint gaslimit = gasleft();
		uint price = oraclize_getPrice(queryType, gasAmount);
		uint balancebefore = address(this).balance;
		require(price <= address(this).balance);
		if (numArtworks<=1) {
			removeArtworksByString("",0);
			distribute(0);
			nextStealId = 0x0;
			price = 0;
		} else {
			nextStealId = oraclize_query(nextStealTimestamp, queryType, randomQuery, gasAmount);
		}
		emit newTriggerOraclize(nextStealId, inseconds, gasAmount, price, balancebefore, address(this).balance);
		oraclizeFee = price + (gaslimit-gasleft() + 200000  ) * tx.gasprice;
	}
	function findIndexFromRandomNumber(uint32 randomNumbers) internal returns (uint32 artworkId, uint16 index) {
		uint16 indexOldest;
		uint maxNumber;
		uint8 extraProbability;
		if (oldest==0)
			lastcombo = 0;
		(artworkId,indexOldest) = setOldest();
		if (lastcombo>oldestExtraStealProbability.length-1)
			extraProbability = oldestExtraStealProbability[oldestExtraStealProbability.length-1];
		else
			extraProbability = oldestExtraStealProbability[lastcombo];
		maxNumber = 100000 - extraProbability*1000;
		if (extraProbability>0 && randomNumbers>maxNumber) {
			index = indexOldest;
			artworkId = oldest;
		} else {
			index = mapToNewRange(randomNumbers, numArtworks, maxNumber);
			artworkId = ids[index];
		}
	}
	function removeArtworksByString(string result,uint32 howmany) internal returns (uint128 pot) {
		uint32[] memory stolenArtworks = new uint32[](howmany);
		uint8[] memory artworkTypes = new uint8[](howmany);
		uint32[] memory sequenceNumbers = new uint32[](howmany);
		uint256[] memory artworkValues = new uint256[](howmany);
		address[] memory players = new address[](howmany);
		if (howmany>0) {
			uint32[] memory randomNumbers = getNumbersFromString(result, ",", howmany);
			uint16 index;
			uint32 artworkId;
			Artwork memory artworkData;
			pot = 0;
			if (oldest!=0)
				lastcombo++;
			for (uint32 i = 0; i < howmany; i++) {
				(artworkId,index) = findIndexFromRandomNumber(randomNumbers[i]);
				artworkData = artworks[artworkId];
				pot += artworkData.value;
				stolenArtworks[i] = artworkId;
				artworkTypes[i] = artworkData.artworkType;
				sequenceNumbers[i] = artworkData.sequenceNumber;
				artworkValues[i] = artworkData.value;
				players[i] = artworkData.player;
				replaceArtwork(index);
			}
		} else {
			pot = 0;
		}
		emit newSteal(now,stolenArtworks,artworkTypes,sequenceNumbers,artworkValues,players);
	}
	function __callback(bytes32 myid, string result) public {
		uint gaslimit = gasleft();
		uint32 howmany;
		uint128 pot;
		uint gasCost;
		uint128 distpot;
		uint oraclizeFeeTmp = 0;  
		if (msg.sender == oraclize_cbAddress() && myid == nextStealId) {
			howmany = numArtworks < 100 ? (numArtworks < 10 ? (numArtworks < 2 ? 0 : 1) : numArtworks / 10) : 10;  
			pot = removeArtworksByString(result,howmany);
			gasCost = ((oraclizeFee * etherExchangeLikeCoin) / 1 ether) * 1 ether + 1 ether ;
			if (pot > gasCost)
				distpot = uint128(pot - gasCost);
			distribute(distpot);  
			oraclizeFeeTmp = oraclizeFee;
			oraclizeFee = 0;
		}
		emit newOraclizeCallback(myid,result,howmany,pot,distpot,oraclizeFeeTmp,gaslimit,etherExchangeLikeCoin);
	}
	function updateNextStealTime(uint32 inseconds) internal {
		nextStealTimestamp = now + inseconds;
	}
	function distribute(uint128 totalAmount) internal {
		uint32 artworkId;
		uint128 amount = ( totalAmount * 60 ) / 100;
		uint128 valueSum = 0;
		uint128 totalAmountRemain = totalAmount;
		uint128[] memory shares = new uint128[](values.length+1);
		if (totalAmount>0) {
			for (uint8 v = 0; v < values.length; v++) {
				if (numArtworksXType[v] > 0) valueSum += values[v];
			}
			for (uint8 m = 0; m < values.length; m++) {
				if (numArtworksXType[m] > 0)
					shares[m] = ((amount * (values[m] * 1000 / valueSum) / numArtworksXType[m]) / (1000 ether)) * (1 ether);
			}
			for (uint16 i = 0; i < numArtworks; i++) {
				artworkId = ids[i];
				amount = shares[artworks[artworkId].artworkType];
				artworks[artworkId].value += amount;
				totalAmountRemain -= amount;
			}
			setOldest();
			artworks[oldest].value += totalAmountRemain;
			shares[shares.length-1] = totalAmountRemain;			
		}
		lastStealBlockNumber = block.number;
		updateNextStealTime(timeTillNextSteal());
		emit newStealRewards(totalAmount,shares);
	}
	function get30Artworks(uint16 startIndex) public constant returns(uint32[] artworkIds,uint8[] types,uint32[] sequenceNumbers, uint128[] artworkValues,address[] players) {
		uint32 endIndex = startIndex + 30 > numArtworks ? numArtworks : startIndex + 30;
		uint32 id;
		uint32 num = endIndex - startIndex;
		artworkIds = new uint32[](num);
		types = new uint8[](num);
		sequenceNumbers = new uint32[](num);
		artworkValues = new uint128[](num);
		players = new address[](num);
		uint16 j = 0;		
		for (uint16 i = startIndex; i < endIndex; i++) {
			id = ids[i];
			artworkIds[j] = id;
			types[j] = artworks[id].artworkType;
			sequenceNumbers[j] = artworks[id].sequenceNumber;
			artworkValues[j] = artworks[id].value;
			players[j] = artworks[id].player;
			j++;
		}
	}
	function getRemainTime() public constant returns(uint remainTime) {
		if (nextStealTimestamp>now) remainTime = nextStealTimestamp - now;
	}
	function setCustomGasPrice(uint gasPrice) public ownerOrOperator {
		oraclize_setCustomGasPrice(gasPrice);
	}
	function setOraclizeGas(uint32 newGas) public ownerOrOperator {
		oraclizeGas = newGas;
	}
	function setOraclizeGasExtraArtwork(uint32 newGas) public ownerOrOperator {
		oraclizeGasExtraArtwork = newGas;
	}
	function setEtherExchangeLikeCoin(uint32 newValue) public ownerOrOperator {
		etherExchangeLikeCoin = newValue;
	}
	function setMaxArtworks(uint16 number) public ownerOrOperator {
		maxArtworks = number;
	}
	function setNumOfTimesSteal(uint8 adjust) public ownerOrOperator {
		numOfTimesSteal = adjust;
	}
	function updateNextStealTimeByOperator(uint32 inseconds) public ownerOrOperator {
		nextStealTimestamp = now + inseconds;
	}
	function mapToNewRange(uint number, uint range, uint max) pure internal returns(uint16 randomNumber) {
		return uint16(number * range / max);
	}
	function getNumbersFromString(string s, string delimiter, uint32 howmany) public pure returns(uint32[] numbers) {
		var s2 = s.toSlice();
		var delim = delimiter.toSlice();
		string[] memory parts = new string[](s2.count(delim) + 1);
		for(uint8 i = 0; i < parts.length; i++) {
			parts[i] = s2.split(delim).toString();
		}
		numbers = new uint32[](howmany);
		if (howmany>parts.length) howmany = uint32(parts.length);
		for (uint8 j = 0; j < howmany; j++) {
			numbers[j] = uint32(parseInt(parts[j]));
		}
		return numbers;
	}
	function tokenCallback(address _from, uint256 _value, bytes _data) public {
		require(msg.sender == address(like));
		uint[] memory result;
		uint len;
		assembly {
			len := mload(_data)
			let c := 0
			result := mload(0x40)
			for { let i := 0 } lt(i, len) { i := add(i, 0x20) }
			{
				mstore(add(result, add(i, 0x20)), mload(add(_data, add(i, 0x20))))
				c := add(c, 1)
			}
			mstore(result, c)
			mstore(0x40, add(result , add(0x20, mul(c, 0x20))))
		}
		uint8[] memory result2 = new uint8[](result.length);
		for (uint16 j=0;j<result.length; j++) {
			result2[j] = uint8(result[j]);
		}
		giveArtworks(result2, _from, _value);
	}
}
