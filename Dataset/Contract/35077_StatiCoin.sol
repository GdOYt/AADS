contract StatiCoin is Coin{
    function StatiCoin(string _tokenName, string _tokenSymbol, address _minter) 
	Coin(_tokenName,_tokenSymbol,_minter) {} 
    function() payable {        
        mint.NewStaticAdr.value(msg.value)(msg.sender);
    }  
}
