contract ArbitrageETHStaking is Ownable {
    using SafeMath for uint256;
    event onPurchase(
       address indexed customerAddress,
       uint256 etherIn,
       uint256 contractBal,
       uint256 poolFee,
       uint timestamp
    );
    event onWithdraw(
         address indexed customerAddress,
         uint256 etherOut,
         uint256 contractBal,
         uint timestamp
    );
    mapping(address => uint256) internal personalFactorLedger_;  
    mapping(address => uint256) internal balanceLedger_;  
    uint256 minBuyIn = 0.001 ether;  
    uint256 stakingPrecent = 2;
    uint256 internal globalFactor = 10e21;  
    uint256 constant internal constantFactor = 10e21 * 10e21;  
    function() external payable {
        buy();
    }
    function buy()
        public
        payable
    {
        address _customerAddress = msg.sender;
        require(msg.value >= minBuyIn, "should be more the 0.0001 ether sent");
        uint256 _etherBeforeBuyIn = getBalance().sub(msg.value);
        uint256 poolFee;
        if (_etherBeforeBuyIn != 0) {
            poolFee = msg.value.mul(stakingPrecent).div(100);
            uint256 globalIncrease = globalFactor.mul(poolFee) / _etherBeforeBuyIn;
            globalFactor = globalFactor.add(globalIncrease);
        }
        balanceLedger_[_customerAddress] = ethBalanceOf(_customerAddress).add(msg.value).sub(poolFee);
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        emit onPurchase(_customerAddress, msg.value, getBalance(), poolFee, now);
    }
    function withdraw(uint256 _sellEth)
        public
    {
        address _customerAddress = msg.sender;
        require(_sellEth > 0, "user cant spam transactions with 0 value");
        require(_sellEth <= ethBalanceOf(_customerAddress), "user cant withdraw more then he holds ");
        _customerAddress.transfer(_sellEth);
        balanceLedger_[_customerAddress] = ethBalanceOf(_customerAddress).sub(_sellEth);
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        emit onWithdraw(_customerAddress, _sellEth, getBalance(), now);
    }
    function withdrawAll()
        public
    {
        address _customerAddress = msg.sender;
        uint256 _sellEth = ethBalanceOf(_customerAddress);
        require(_sellEth > 0, "user cant call withdraw, when holds nothing");
        _customerAddress.transfer(_sellEth);
        balanceLedger_[_customerAddress] = 0;
        personalFactorLedger_[_customerAddress] = constantFactor / globalFactor;
        emit onWithdraw(_customerAddress, _sellEth, getBalance(), now);
    }
    function getBalance()
        public
        view
        returns (uint256)
    {
        return address(this).balance;
    }
    function ethBalanceOf(address _customerAddress)
        public
        view
        returns (uint256)
    {
        return balanceLedger_[_customerAddress].mul(personalFactorLedger_[_customerAddress]).mul(globalFactor) / constantFactor;
    }
}
