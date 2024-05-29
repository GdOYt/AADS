contract MultiMerkleMine {
	using SafeMath for uint256;
	function multiGenerate(address _merkleMineContract, address[] _recipients, bytes _merkleProofs) public {
		MerkleMine mine = MerkleMine(_merkleMineContract);
		ERC20 token = ERC20(mine.token());
		require(
			block.number >= mine.callerAllocationStartBlock(),
			"caller allocation period has not started"
		);
		uint256 initialBalance = token.balanceOf(this);
		bytes[] memory proofs = new bytes[](_recipients.length);
		uint256 i = 0;
		uint256 j = 0;
		while(i < _merkleProofs.length){
			uint256 proofSize = uint256(BytesUtil.readBytes32(_merkleProofs, i));
			require(
				proofSize % 32 == 0,
				"proof size must be a multiple of 32"
			);
			proofs[j] = BytesUtil.substr(_merkleProofs, i + 32, proofSize);
			i = i + 32 + proofSize;
			j++;
		}
		require(
			_recipients.length == j,
			"number of recipients != number of proofs"
		);
		for (uint256 k = 0; k < _recipients.length; k++) {
			if (!mine.generated(_recipients[k])) {
				mine.generate(_recipients[k], proofs[k]);
			}
		}
		uint256 newBalanceSinceAllocation = token.balanceOf(this);
		uint256 callerTokensGenerated = newBalanceSinceAllocation.sub(initialBalance);
		if (callerTokensGenerated > 0) {
			require(token.transfer(msg.sender, callerTokensGenerated));
		}
	}
}
