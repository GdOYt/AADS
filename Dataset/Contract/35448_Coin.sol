contract Coin is StandardToken, mortal{
    I_minter public mint;				   
    event EventClear();
    function Coin(string _tokenName, string _tokenSymbol) { 
        name = _tokenName;                                    
        symbol = _tokenSymbol;                                
    }
    function setMinter(address _minter) external onlyOwner {
        changeOwner(_minter);
        mint=I_minter(_minter);    
    }   
}
