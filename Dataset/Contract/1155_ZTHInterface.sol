contract ZTHInterface {
        function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass) public payable returns (uint);
        function balanceOf(address who) public view returns (uint);
        function transfer(address _to, uint _value)     public returns (bool);
        function transferFrom(address _from, address _toAddress, uint _amountOfTokens) public returns (bool);
        function exit() public;
        function sell(uint amountOfTokens) public;
        function withdraw(address _recipient) public;
}
