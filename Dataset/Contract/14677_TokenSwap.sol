contract TokenSwap {
    address public constant OLD_TOKEN = 0x4306ce4a5d8b21ee158cb8396a4f6866f14d6ac8;
    CoinvestToken public newToken;
    constructor() 
      public 
    {
        newToken = new CoinvestToken();
    }
    function tokenFallback(address _from, uint _value, bytes _data) 
      external
    {
        require(msg.sender == OLD_TOKEN);           
        require(newToken.transfer(_from, _value));  
    }
}
