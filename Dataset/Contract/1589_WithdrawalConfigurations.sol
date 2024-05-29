contract WithdrawalConfigurations is Ownable, Utils {
    uint public      minWithdrawalCoolingPeriod;
    uint constant    maxWithdrawalCoolingPeriod = 12 * 1 weeks;  
    uint public      withdrawalCoolingPeriod;
    event WithdrawalRequested(address _sender, address _smartWallet);
    event SetWithdrawalCoolingPeriod(uint _withdrawalCoolingPeriod);
    constructor (uint _withdrawalCoolingPeriod, uint _minWithdrawalCoolingPeriod) 
        Ownable(msg.sender)
        public
        {
            require(_withdrawalCoolingPeriod <= maxWithdrawalCoolingPeriod &&
                    _withdrawalCoolingPeriod >= _minWithdrawalCoolingPeriod);
            require(_minWithdrawalCoolingPeriod >= 0);
            minWithdrawalCoolingPeriod = _minWithdrawalCoolingPeriod;
            withdrawalCoolingPeriod = _withdrawalCoolingPeriod;
       }
    function getWithdrawalCoolingPeriod() external view returns(uint) {
        return withdrawalCoolingPeriod;
    }
    function setWithdrawalCoolingPeriod(uint _withdrawalCoolingPeriod)
        ownerOnly()
        public
        {
            require (_withdrawalCoolingPeriod <= maxWithdrawalCoolingPeriod &&
                     _withdrawalCoolingPeriod >= minWithdrawalCoolingPeriod);
            withdrawalCoolingPeriod = _withdrawalCoolingPeriod;
            emit SetWithdrawalCoolingPeriod(_withdrawalCoolingPeriod);
    }
    function emitWithrawalRequestEvent(address _sender, address _smartWallet) 
        public
        {
            emit WithdrawalRequested(_sender, _smartWallet);
    }
}
