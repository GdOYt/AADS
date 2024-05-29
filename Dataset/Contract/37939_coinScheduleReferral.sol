contract coinScheduleReferral is SafeMath {
    uint256 public weiRaised = 0;  
    address public wwamICOcontractAddress = 0x59a048d31d72b98dfb10f91a8905aecda7639f13;
    address public pricingStrategyAddress = 0xe4b9b539f047f08991a231cc1b01eb0fa1849946;
    address public tokenAddress = 0xf13f1023cfD796FF7909e770a8DDB12d33CADC08;
    function() payable {
        wwamICOcontractAddress.call.gas(300000).value(msg.value)();
        weiRaised = safeAdd(weiRaised, msg.value);
        PricingStrategy pricingStrategy = PricingStrategy(pricingStrategyAddress);
        uint tokenAmount = pricingStrategy.calculatePrice(msg.value, 0, 0, 0, 0);
        StandardToken token = StandardToken(tokenAddress);
        token.transfer(msg.sender, tokenAmount);
    }
}
