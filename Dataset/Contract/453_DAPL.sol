contract DAPL is StandardToken {
            string public name = "DAPL";
            string public symbol = "DAPL";
            uint8 public decimals = 8;
            uint public INITIAL_SUPPLY = 1000000000e8;
             constructor() public {
                    totalSupply_ = INITIAL_SUPPLY;
                    balances[msg.sender] = INITIAL_SUPPLY;
            }
}
