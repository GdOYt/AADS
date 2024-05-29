contract MultiSend is Ownable {
	using SafeMath for uint256;
	Peculium public pecul;  
	address public peculAdress = 0x3618516f45cd3c913f81f9987af41077932bc40d;  
	uint256 public decimals;  
	function MultiSend() public{
		pecul = Peculium(peculAdress);	
		decimals = pecul.decimals();
	}
	function Send(address[] _vaddr, uint256[] _vamounts) onlyOwner 
	{
		require ( _vaddr.length == _vamounts.length );
		uint256 amountToSendTotal = 0;
		for (uint256 indexTest=0; indexTest<_vaddr.length; indexTest++)  
		{
			amountToSendTotal = amountToSendTotal + _vamounts[indexTest]; 
		}
		require(amountToSendTotal*10**decimals<=pecul.balanceOf(this));  
		for (uint256 index=0; index<_vaddr.length; index++) 
		{
			address toAddress = _vaddr[index];
			uint256 amountTo_Send = _vamounts[index]*10**decimals;
	                pecul.transfer(toAddress,amountTo_Send);
		}
	}
}
