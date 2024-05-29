contract TangguoTaoToken is PausableToken{
   string public name = "TangguoTao Token";
   string public symbol = "TCA";
   uint8 public decimals = 18;
   uint public INITIAL_SUPPLY = 60000000000000000000000000000;
   constructor() public {
       totalSupply_ = INITIAL_SUPPLY;
       balances[msg.sender] = INITIAL_SUPPLY;
   }
}
