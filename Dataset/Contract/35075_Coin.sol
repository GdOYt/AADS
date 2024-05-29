contract Coin is StandardToken, mortal{
    I_minter public mint;				   
    event EventClear();
    function Coin(string _tokenName, string _tokenSymbol, address _minter) { 
        name = _tokenName;                                    
        symbol = _tokenSymbol;                                
        changeOwner(_minter);
        mint=I_minter(_minter); 
	}
}
