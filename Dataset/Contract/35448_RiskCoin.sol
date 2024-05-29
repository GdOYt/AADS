contract RiskCoin is Coin{
    function RiskCoin(string _tokenName, string _tokenSymbol) 
	Coin(_tokenName,_tokenSymbol) {} 
    function() payable {
        mint.NewRiskAdr.value(msg.value)(msg.sender);
    }  
}
