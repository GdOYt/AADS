contract Delivery is Ownable{
	using SafeMath for uint256;
	uint256 public Airdropsamount;  
	uint256 public decimals;  
	Peculium public pecul;  
	bool public initPecul;  
	event AirdropOne(address airdropaddress,uint256 nbTokenSendAirdrop);  
	event AirdropList(address[] airdropListAddress,uint256[] listTokenSendAirdrop);  
	event InitializedToken(address contractToken);
	function Delivery(){
		Airdropsamount = 28000000;  
		initPecul = false;
	}
	function InitPeculiumAdress(address peculAdress) onlyOwner
	{  
		pecul = Peculium(peculAdress);
		decimals = pecul.decimals();
		initPecul = true;
		InitializedToken(peculAdress);
	}
	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner Initialize NotEmpty 
	{ 
		require (Airdropsamount >0);
		require ( _vaddr.length == _vamounts.length );
		uint256 amountToSendTotal = 0;
		for (uint256 indexTest=0; indexTest<_vaddr.length; indexTest++)  
		{
			amountToSendTotal.add(_vamounts[indexTest]); 
		}		
		require(amountToSendTotal<=Airdropsamount);  
		for (uint256 index=0; index<_vaddr.length; index++) 
		{
			address toAddress = _vaddr[index];
			uint256 amountTo_Send = _vamounts[index].mul(10 ** decimals);
	                pecul.transfer(toAddress,amountTo_Send);
			AirdropOne(toAddress,amountTo_Send);
		}
		Airdropsamount = Airdropsamount.sub(amountToSendTotal);
		AirdropList(_vaddr,_vamounts);
	}
	modifier NotEmpty {
		require (Airdropsamount>0);
		_;
	}
	modifier Initialize {
	require (initPecul==true);
	_;
	} 
    }
