contract SparksterToken is StandardToken, Ownable{
	using strings for *;
	using SafeMath for uint256;
	struct Member {
		address walletAddress;
		mapping(uint256 => bool) groupMemberships;  
		mapping(uint256 => uint256) ethBalance;  
		mapping(uint256 => uint256) tokenBalance;  
		uint256 max1;  
		int256 transferred;  
		bool exists;  
	}
	struct Group {
		bool distributed;  
		bool distributing;  
		bool unlocked;  
		uint256 groupNumber;  
		uint256 ratio;  
		uint256 startTime;  
		uint256 phase1endTime;  
		uint256 phase2endTime;  
		uint256 deadline;  
		uint256 max2;  
		uint256 max3;  
		uint256 ethTotal;  
		uint256 cap;  
		uint256 howManyDistributed;
	}
	bool internal transferLock = true;  
	bool internal allowedToSell = false;
	bool internal allowedToPurchase = false;
	string public name;									  
	string public symbol;								  
	uint8 public decimals;							 
	uint256 internal maxGasPrice;  
	uint256 internal nextGroupNumber;
	uint256 public sellPrice;  
	address[] internal allMembers;	
	address[] internal allNonMembers;
	mapping(address => bool) internal nonMemberTransfers;
	mapping(address => Member) internal members;
	mapping(uint256 => Group) internal groups;
	mapping(uint256 => address[]) internal associations;  
	uint256 internal openGroupNumber;
	event PurchaseSuccess(address indexed _addr, uint256 _weiAmount,uint256 _totalEthBalance,uint256 _totalTokenBalance);
	event DistributeDone(uint256 groupNumber);
	event UnlockDone(uint256 groupNumber);
	event GroupCreated(uint256 groupNumber, uint256 startTime, uint256 phase1endTime, uint256 phase2endTime, uint256 deadline, uint256 phase2cap, uint256 phase3cap, uint256 cap, uint256 ratio);
	event ChangedAllowedToSell(bool allowedToSell);
	event ChangedAllowedToPurchase(bool allowedToPurchase);
	event ChangedTransferLock(bool transferLock);
	event SetSellPrice(uint256 sellPrice);
	event Added(address walletAddress, uint256 group, uint256 tokens, uint256 maxContribution1);
	event SplitTokens(uint256 splitFactor);
	event ReverseSplitTokens(uint256 splitFactor);
	modifier onlyPayloadSize(uint size) {	 
		require(msg.data.length == size + 4);
		_;
	}
	modifier canTransfer() {
		require(!transferLock);
		_;
	}
	modifier canPurchase() {
		require(allowedToPurchase);
		_;
	}
	modifier canSell() {
		require(allowedToSell);
		_;
	}
	function() public payable {
		purchase();
	}
	constructor() public {
		name = "Sparkster";									 
		decimals = 18;					  
		symbol = "SPRK";							 
		setMaximumGasPrice(40);
		mintTokens(435000000);
	}
	function setMaximumGasPrice(uint256 gweiPrice) public onlyOwner returns(bool success) {
		maxGasPrice = gweiPrice.mul(10**9);  
		return true;
	}
	function parseAddr(string _a) pure internal returns (address){  
		bytes memory tmp = bytes(_a);
		uint160 iaddr = 0;
		uint160 b1;
		uint160 b2;
		for (uint i=2; i<2+2*20; i+=2){
			iaddr *= 256;
			b1 = uint160(tmp[i]);
			b2 = uint160(tmp[i+1]);
			if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
			else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
			if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
			else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
			iaddr += (b1*16+b2);
		}
		return address(iaddr);
	}
	function parseInt(string _a, uint _b) pure internal returns (uint) {
		bytes memory bresult = bytes(_a);
		uint mint = 0;
		bool decim = false;
		for (uint i = 0; i < bresult.length; i++) {
			if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
				if (decim) {
					if (_b == 0) break;
						else _b--;
				}
				mint *= 10;
				mint += uint(bresult[i]) - 48;
			} else if (bresult[i] == 46) decim = true;
		}
		return mint;
	}
	function mintTokens(uint256 amount) public onlyOwner {
		uint256 decimalAmount = amount.mul(uint(10)**decimals);
		totalSupply_ = totalSupply_.add(decimalAmount);
		balances[msg.sender] = balances[msg.sender].add(decimalAmount);
		emit Transfer(address(0), msg.sender, decimalAmount);  
	}
	function purchase() public canPurchase payable{
		require(msg.sender != address(0));  
		Member storage memberRecord = members[msg.sender];
		Group storage openGroup = groups[openGroupNumber];
		require(openGroup.ratio > 0);  
		require(memberRecord.exists && memberRecord.groupMemberships[openGroup.groupNumber] && !openGroup.distributing && !openGroup.distributed && !openGroup.unlocked);  
		uint256 currentTimestamp = block.timestamp;
		require(currentTimestamp >= openGroup.startTime && currentTimestamp <= openGroup.deadline);																  
		require(tx.gasprice <= maxGasPrice);  
		uint256 weiAmount = msg.value;																		 
		require(weiAmount >= 0.1 ether);
		uint256 ethTotal = openGroup.ethTotal.add(weiAmount);  
		require(ethTotal <= openGroup.cap);														 
		uint256 userETHTotal = memberRecord.ethBalance[openGroup.groupNumber].add(weiAmount);	 
		if(currentTimestamp <= openGroup.phase1endTime){																			  
			require(userETHTotal <= memberRecord.max1);														  
		} else if (currentTimestamp <= openGroup.phase2endTime) {  
			require(userETHTotal <= openGroup.max2);  
		} else {  
			require(userETHTotal <= openGroup.max3);  
		}
		uint256 tokenAmount = weiAmount.mul(openGroup.ratio);						  
		uint256 newLeftOver = balances[owner].sub(tokenAmount);  
		openGroup.ethTotal = ethTotal;								  
		memberRecord.ethBalance[openGroup.groupNumber] = userETHTotal;														  
		memberRecord.tokenBalance[openGroup.groupNumber] = memberRecord.tokenBalance[openGroup.groupNumber].add(tokenAmount);  
		balances[owner] = newLeftOver;  
		owner.transfer(weiAmount);  
		emit PurchaseSuccess(msg.sender,weiAmount,memberRecord.ethBalance[openGroup.groupNumber],memberRecord.tokenBalance[openGroup.groupNumber]); 
	}
	function sell(uint256 amount) public canSell {  
		uint256 decimalAmount = amount.mul(uint(10)**decimals);  
		if (members[msg.sender].exists) {  
			int256 sellValue = members[msg.sender].transferred + int(decimalAmount);
			require(sellValue >= members[msg.sender].transferred);  
			require(sellValue <= int(getUnlockedBalanceLimit(msg.sender)));  
			members[msg.sender].transferred = sellValue;
		}
		balances[msg.sender] = balances[msg.sender].sub(decimalAmount);  
		uint256 totalCost = amount.mul(sellPrice);  
		require(address(this).balance >= totalCost);  
		balances[owner] = balances[owner].add(decimalAmount);  
		msg.sender.transfer(totalCost);  
		emit Transfer(msg.sender, owner, decimalAmount);  
	}
	function fundContract() public onlyOwner payable {  
	}
	function setSellPrice(uint256 thePrice) public onlyOwner {
		sellPrice = thePrice;
		emit SetSellPrice(sellPrice);
	}
	function setAllowedToSell(bool value) public onlyOwner {
		allowedToSell = value;
		emit ChangedAllowedToSell(allowedToSell);
	}
	function setAllowedToPurchase(bool value) public onlyOwner {
		allowedToPurchase = value;
		emit ChangedAllowedToPurchase(allowedToPurchase);
	}
	function createGroup(uint256 startEpoch, uint256 phase1endEpoch, uint256 phase2endEpoch, uint256 deadlineEpoch, uint256 phase2cap, uint256 phase3cap, uint256 etherCap, uint256 ratio) public onlyOwner returns (bool success, uint256 createdGroupNumber) {
		Group storage theGroup = groups[nextGroupNumber];
		theGroup.groupNumber = nextGroupNumber;
		theGroup.startTime = startEpoch;
		theGroup.phase1endTime = phase1endEpoch;
		theGroup.phase2endTime = phase2endEpoch;
		theGroup.deadline = deadlineEpoch;
		theGroup.max2 = phase2cap;
		theGroup.max3 = phase3cap;
		theGroup.cap = etherCap;
		theGroup.ratio = ratio;
		createdGroupNumber = nextGroupNumber;
		nextGroupNumber++;
		success = true;
		emit GroupCreated(createdGroupNumber, startEpoch, phase1endEpoch, phase2endEpoch, deadlineEpoch, phase2cap, phase3cap, etherCap, ratio);
	}
	function createGroup() public onlyOwner returns (bool success, uint256 createdGroupNumber) {
		return createGroup(0, 0, 0, 0, 0, 0, 0, 0);
	}
	function getGroup(uint256 groupNumber) public view onlyOwner returns(bool distributed, bool unlocked, uint256 phase2cap, uint256 phase3cap, uint256 cap, uint256 ratio, uint256 startTime, uint256 phase1endTime, uint256 phase2endTime, uint256 deadline, uint256 ethTotal, uint256 howManyDistributed) {
		require(groupNumber < nextGroupNumber);
		Group storage theGroup = groups[groupNumber];
		distributed = theGroup.distributed;
		unlocked = theGroup.unlocked;
		phase2cap = theGroup.max2;
		phase3cap = theGroup.max3;
		cap = theGroup.cap;
		ratio = theGroup.ratio;
		startTime = theGroup.startTime;
		phase1endTime = theGroup.phase1endTime;
		phase2endTime = theGroup.phase2endTime;
		deadline = theGroup.deadline;
		ethTotal = theGroup.ethTotal;
		howManyDistributed = theGroup.howManyDistributed;
	}
	function getHowManyLeftToDistribute(uint256 groupNumber) public view returns(uint256 howManyLeftToDistribute) {
		require(groupNumber < nextGroupNumber);
		Group storage theGroup = groups[groupNumber];
		howManyLeftToDistribute = associations[groupNumber].length - theGroup.howManyDistributed;  
	}
	function getMembersInGroup(uint256 groupNumber) public view returns (address[]) {
		require(groupNumber < nextGroupNumber);  
		return associations[groupNumber];
	}
	function addMember(address walletAddress, uint256 groupNumber, uint256 tokens, uint256 maxContribution1) public onlyOwner returns (bool success) {
		Member storage theMember = members[walletAddress];
		Group storage theGroup = groups[groupNumber];
		require(groupNumber < nextGroupNumber);  
		require(!theGroup.distributed && !theGroup.distributing && !theGroup.unlocked);  
		require(!theMember.exists);  
		theMember.walletAddress = walletAddress;
		theMember.groupMemberships[groupNumber] = true;
		balances[owner] = balances[owner].sub(tokens);
		theMember.tokenBalance[groupNumber] = tokens;
		theMember.max1 = maxContribution1;
		theMember.transferred = -int(balances[walletAddress]);  
		theMember.exists = true;
		associations[groupNumber].push(walletAddress);  
		allMembers.push(walletAddress);  
		emit Added(walletAddress, groupNumber, tokens, maxContribution1);
		return true;
	}
	function addMemberToGroup(address walletAddress, uint256 groupNumber) public onlyOwner returns(bool success) {
		Member storage memberRecord = members[walletAddress];
		require(memberRecord.exists && groupNumber < nextGroupNumber && !memberRecord.groupMemberships[groupNumber]);  
		memberRecord.groupMemberships[groupNumber] = true;
		associations[groupNumber].push(walletAddress);
		return true;
	}
	function upload(string uploadedData) public onlyOwner returns (bool success) {
		strings.slice memory uploadedSlice = uploadedData.toSlice();
		strings.slice memory nextRecord = "".toSlice();
		strings.slice memory nextDatum = "".toSlice();
		strings.slice memory recordSeparator = "|".toSlice();
		strings.slice memory datumSeparator = ":".toSlice();
		while (!uploadedSlice.empty()) {
			nextRecord = uploadedSlice.split(recordSeparator);
			nextDatum = nextRecord.split(datumSeparator);
			address memberAddress = parseAddr(nextDatum.toString());
			nextDatum = nextRecord.split(datumSeparator);
			uint256 memberGroup = parseInt(nextDatum.toString(), 0);
			nextDatum = nextRecord.split(datumSeparator);
			uint256 memberTokens = parseInt(nextDatum.toString(), 0);
			nextDatum = nextRecord.split(datumSeparator);
			uint256 memberMaxContribution1 = parseInt(nextDatum.toString(), 0);
			addMember(memberAddress, memberGroup, memberTokens, memberMaxContribution1);
		}
		return true;
	}
	function distribute(uint256 groupNumber, uint256 howMany) public onlyOwner returns (bool success) {
		Group storage theGroup = groups[groupNumber];
		require(groupNumber < nextGroupNumber && !theGroup.distributed );  
		uint256 inclusiveStartIndex = theGroup.howManyDistributed;
		uint256 exclusiveEndIndex = inclusiveStartIndex.add(howMany);
		theGroup.distributing = true;
		uint256 n = associations[groupNumber].length;
		require(n > 0 );  
		if (exclusiveEndIndex > n) {  
			exclusiveEndIndex = n;
		}
		for (uint256 i = inclusiveStartIndex; i < exclusiveEndIndex; i++) {  
			address memberAddress = associations[groupNumber][i];
			Member storage currentMember = members[memberAddress];
			uint256 balance = currentMember.tokenBalance[groupNumber];
			if (balance > 0) {  
				balances[memberAddress] = balances[memberAddress].add(balance);
				emit Transfer(owner, memberAddress, balance);  
			}
			theGroup.howManyDistributed++;
		}
		if (theGroup.howManyDistributed == n) {  
			theGroup.distributed = true;
			theGroup.distributing = false;
			emit DistributeDone(groupNumber);
		}
		return true;
	}
	function getUnlockedBalanceLimit(address walletAddress) internal view returns(uint256 balance) {
		Member storage theMember = members[walletAddress];
		if (!theMember.exists) {
			return balances[walletAddress];
		}
		for (uint256 i = 0; i < nextGroupNumber; i++) {
			if (groups[i].unlocked) {
				balance = balance.add(theMember.tokenBalance[i]);
			}
		}
		return balance;
	}
	function getUnlockedTokens(address walletAddress) public view returns(uint256 balance) {
		Member storage theMember = members[walletAddress];
		if (!theMember.exists) {
			return balances[walletAddress];
		}
		return uint256(int(getUnlockedBalanceLimit(walletAddress)) - theMember.transferred);
	}
	function unlock(uint256 groupNumber) public onlyOwner returns (bool success) {
		Group storage theGroup = groups[groupNumber];
		require(theGroup.distributed && !theGroup.unlocked);  
		theGroup.unlocked = true;
		emit UnlockDone(groupNumber);
		return true;
	}
	function setTransferLock(bool value) public onlyOwner {
		transferLock = value;
		emit ChangedTransferLock(transferLock);
	}
	function burn(uint256 amount) public onlyOwner {
		balances[msg.sender] = balances[msg.sender].sub(amount);  
		totalSupply_ = totalSupply_.sub(amount);  
		emit Transfer(msg.sender, address(0), amount);
	}
	function splitTokensBeforeDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {
		uint256 n = allMembers.length;
		uint256 ownerBalance = balances[msg.sender];
		uint256 increaseSupplyBy = ownerBalance.mul(splitFactor).sub(ownerBalance);  
		balances[msg.sender] = balances[msg.sender].mul(splitFactor);
		totalSupply_ = totalSupply_.mul(splitFactor);
		emit Transfer(address(0), msg.sender, increaseSupplyBy);  
		for (uint256 i = 0; i < n; i++) {
			Member storage currentMember = members[allMembers[i]];
			currentMember.transferred = currentMember.transferred * int(splitFactor);
			for (uint256 j = 0; j < nextGroupNumber; j++) {
				uint256 memberBalance = currentMember.tokenBalance[j];
				uint256 multiplier = memberBalance.mul(splitFactor);
				currentMember.tokenBalance[j] = multiplier;
			}
		}
		n = nextGroupNumber;
		require(n > 0);  
		for (i = 0; i < n; i++) {
			Group storage currentGroup = groups[i];
			currentGroup.ratio = currentGroup.ratio.mul(splitFactor);
		}
		emit SplitTokens(splitFactor);
		return true;
	}
	function reverseSplitTokensBeforeDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {
		uint256 n = allMembers.length;
		uint256 ownerBalance = balances[msg.sender];
		uint256 decreaseSupplyBy = ownerBalance.sub(ownerBalance.div(splitFactor));
		totalSupply_ = totalSupply_.div(splitFactor);
		balances[msg.sender] = ownerBalance.div(splitFactor);
		emit Transfer(msg.sender, address(0), decreaseSupplyBy);
		for (uint256 i = 0; i < n; i++) {
			Member storage currentMember = members[allMembers[i]];
			currentMember.transferred = currentMember.transferred / int(splitFactor);
			for (uint256 j = 0; j < nextGroupNumber; j++) {
				uint256 memberBalance = currentMember.tokenBalance[j];
				uint256 divier = memberBalance.div(splitFactor);
				currentMember.tokenBalance[j] = divier;
			}
		}
		n = nextGroupNumber;
		require(n > 0);  
		for (i = 0; i < n; i++) {
			Group storage currentGroup = groups[i];
			currentGroup.ratio = currentGroup.ratio.div(splitFactor);
		}
		emit ReverseSplitTokens(splitFactor);
		return true;
	}
	function splitTokensAfterDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {
		splitTokensBeforeDistribution(splitFactor);
		uint256 n = allMembers.length;
		for (uint256 i = 0; i < n; i++) {
			address currentMember = allMembers[i];
			uint256 memberBalance = balances[currentMember];
			if (memberBalance > 0) {
				uint256 multiplier1 = memberBalance.mul(splitFactor);
				uint256 increaseMemberSupplyBy = multiplier1.sub(memberBalance);
				balances[currentMember] = multiplier1;
				emit Transfer(address(0), currentMember, increaseMemberSupplyBy);
			}
		}
		n = allNonMembers.length;
		for (i = 0; i < n; i++) {
			address currentNonMember = allNonMembers[i];
			if (members[currentNonMember].exists) {
				continue;
			}
			uint256 nonMemberBalance = balances[currentNonMember];
			if (nonMemberBalance > 0) {
				uint256 multiplier2 = nonMemberBalance.mul(splitFactor);
				uint256 increaseNonMemberSupplyBy = multiplier2.sub(nonMemberBalance);
				balances[currentNonMember] = multiplier2;
				emit Transfer(address(0), currentNonMember, increaseNonMemberSupplyBy);
			}
		}
		emit SplitTokens(splitFactor);
		return true;
	}
	function reverseSplitTokensAfterDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {
		reverseSplitTokensBeforeDistribution(splitFactor);
		uint256 n = allMembers.length;
		for (uint256 i = 0; i < n; i++) {
			address currentMember = allMembers[i];
			uint256 memberBalance = balances[currentMember];
			if (memberBalance > 0) {
				uint256 divier1 = memberBalance.div(splitFactor);
				uint256 decreaseMemberSupplyBy = memberBalance.sub(divier1);
				balances[currentMember] = divier1;
				emit Transfer(currentMember, address(0), decreaseMemberSupplyBy);
			}
		}
		n = allNonMembers.length;
		for (i = 0; i < n; i++) {
			address currentNonMember = allNonMembers[i];
			if (members[currentNonMember].exists) {
				continue;
			}
			uint256 nonMemberBalance = balances[currentNonMember];
			if (nonMemberBalance > 0) {
				uint256 divier2 = nonMemberBalance.div(splitFactor);
				uint256 decreaseNonMemberSupplyBy = nonMemberBalance.sub(divier2);
				balances[currentNonMember] = divier2;
				emit Transfer(currentNonMember, address(0), decreaseNonMemberSupplyBy);
			}
		}
		emit ReverseSplitTokens(splitFactor);
		return true;
	}
	function changeMaxContribution(address memberAddress, uint256 newMax1) public onlyOwner {
		Member storage theMember = members[memberAddress];
		require(theMember.exists);  
		theMember.max1 = newMax1;
	}
	function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) canTransfer returns (bool success) {		
		Member storage fromMember = members[msg.sender];
		if (fromMember.exists) {  
			int256 transferValue = fromMember.transferred + int(_value);
			require(transferValue >= fromMember.transferred);  
			require(transferValue <= int(getUnlockedBalanceLimit(msg.sender)));  
			fromMember.transferred = transferValue;
		}
		if (!fromMember.exists && msg.sender != owner) {
			bool fromTransferee = nonMemberTransfers[msg.sender];
			if (!fromTransferee) {  
				nonMemberTransfers[msg.sender] = true;
				allNonMembers.push(msg.sender);
			}
		}
		if (!members[_to].exists && _to != owner) {
			bool toTransferee = nonMemberTransfers[_to];
			if (!toTransferee) {  
				nonMemberTransfers[_to] = true;
				allNonMembers.push(_to);
			}
		} else if (members[_to].exists) {  
			int256 transferInValue = members[_to].transferred - int(_value);
			require(transferInValue <= members[_to].transferred);  
			members[_to].transferred = transferInValue;
		}
		return super.transfer(_to, _value);
	}
	function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) canTransfer returns (bool success) {
		Member storage fromMember = members[_from];
		if (fromMember.exists) {  
			int256 transferValue = fromMember.transferred + int(_value);
			require(transferValue >= fromMember.transferred);  
			require(transferValue <= int(getUnlockedBalanceLimit(msg.sender)));  
			fromMember.transferred = transferValue;
		}
		if (!fromMember.exists && _from != owner) {
			bool fromTransferee = nonMemberTransfers[_from];
			if (!fromTransferee) {  
				nonMemberTransfers[_from] = true;
				allNonMembers.push(_from);
			}
		}
		if (!members[_to].exists && _to != owner) {
			bool toTransferee = nonMemberTransfers[_to];
			if (!toTransferee) {  
				nonMemberTransfers[_to] = true;
				allNonMembers.push(_to);
			}
		} else if (members[_to].exists) {  
			int256 transferInValue = members[_to].transferred - int(_value);
			require(transferInValue <= members[_to].transferred);  
			members[_to].transferred = transferInValue;
		}
		return super.transferFrom(_from, _to, _value);
	}
	function setOpenGroup(uint256 groupNumber) public onlyOwner returns (bool success) {
		require(groupNumber < nextGroupNumber);
		openGroupNumber = groupNumber;
		return true;
	}
	function getUndistributedBalanceOf(address walletAddress, uint256 groupNumber) public view returns (uint256 balance) {
		Member storage theMember = members[walletAddress];
		require(theMember.exists);
		if (groups[groupNumber].distributed)  
			return 0;
		return theMember.tokenBalance[groupNumber];
	}
	function checkMyUndistributedBalance(uint256 groupNumber) public view returns (uint256 balance) {
		return getUndistributedBalanceOf(msg.sender, groupNumber);
	}
	function transferRecovery(address _from, address _to, uint256 _value) public onlyOwner returns (bool success) {
		allowed[_from][msg.sender] = allowed[_from][msg.sender].add(_value);  
		Member storage fromMember = members[_from];
		if (fromMember.exists) {
			int256 oldTransferred = fromMember.transferred;
			fromMember.transferred -= int(_value);  
			require(oldTransferred >= fromMember.transferred);  
		}
		return transferFrom(_from, _to, _value);
	}
}
