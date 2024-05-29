contract RiskCoin is Coin{
    function RiskCoin(string _tokenName, string _tokenSymbol, address _minter) 
	Coin(_tokenName,_tokenSymbol,_minter) {} 
    function() payable {
        mint.NewRiskAdr.value(msg.value)(msg.sender);
    }  
}
