contract StarmidFreezeTokens {
	StarmidTransfer public StarmidFunc;
	address public owner;
	constructor(address _addr) {
		StarmidFunc = StarmidTransfer(_addr);
		owner = 0x378B9eea7ab9C15d9818EAdDe1156A079Cd02ba8;
	}
	function refundTokens(address _to, uint _amount) public returns(bool) {
			require(block.timestamp > 1601510400 && msg.sender == owner); 
			StarmidFunc.transfer(_to,_amount);
			return true;
		}
}
