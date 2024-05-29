contract BSPCP is StandardToken, DetailedERC20, BurnableToken, MintableToken {
    constructor(string _name, string _symbol, uint8 _decimals) 
        DetailedERC20(_name, _symbol, _decimals) 
        public 
    {
    }
}
