contract pricerControl is canFreeze {
    I_Pricer public pricer;
    address public future;
    uint256 public releaseTime;
    uint public PRICER_DELAY = 2;  
    event EventAddressChange(address indexed _from, address indexed _to, uint _timeChange);
    function setPricer(address newAddress) onlyOwner {
        releaseTime = now + PRICER_DELAY;
        future = newAddress;
        EventAddressChange(pricer, future, releaseTime);
    }  
    modifier updates() {
        if (now > releaseTime  && pricer != future){
            update();
        }
        _;
    }
    modifier onlyPricer() {
      require(msg.sender==address(pricer));
      _;
    }
    function update() internal {
        pricer =  I_Pricer(future);
		frozen = false;
    }
}
