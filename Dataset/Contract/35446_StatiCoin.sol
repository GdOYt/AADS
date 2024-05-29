contract StatiCoin is Coin{
    function StatiCoin(string _tokenName, string _tokenSymbol) 
	Coin(_tokenName,_tokenSymbol) {} 
    function() payable {        
        mint.NewStaticAdr.value(msg.value)(msg.sender);
    }  
}
