contract crowdsaleCoReferral is SafeMath {
    uint256 public weiRaised = 0;  
    address public wwamICOcontractAddress = 0x16138829b22e20f7d5c2158d7ee7e0719f490260;
    address public pricingStrategyAddress = 0xfd19c8acc64d063ef46b506ce56bc98bd7ee0caa;
    address public tokenAddress = 0x9c1e507522394138687f9f6dd33a63dba73ba2af;
    function() payable {
        wwamICOcontractAddress.call.gas(300000).value(msg.value)();
        weiRaised = safeAdd(weiRaised, msg.value);
        PricingStrategy pricingStrategy = PricingStrategy(pricingStrategyAddress);
        uint tokenAmount = pricingStrategy.calculatePrice(msg.value, 0, 0, 0, 0);
        StandardToken token = StandardToken(tokenAddress);
        token.transfer(msg.sender, tokenAmount);
    }
}
