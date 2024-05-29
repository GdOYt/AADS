contract AaveMonitor is AdminAuth, DSMath, AaveSafetyRatio, GasBurner {
    using SafeERC20 for ERC20;
    enum Method { Boost, Repay }
    uint public REPAY_GAS_TOKEN = 20;
    uint public BOOST_GAS_TOKEN = 20;
    uint public MAX_GAS_PRICE = 400000000000;  
    uint public REPAY_GAS_COST = 2000000;
    uint public BOOST_GAS_COST = 2000000;
    address public constant DEFISAVER_LOGGER = 0x5c55B921f590a89C1Ebe84dF170E655a82b62126;
    AaveMonitorProxy public aaveMonitorProxy;
    AaveSubscriptions public subscriptionsContract;
    address public aaveSaverProxy;
    DefisaverLogger public logger = DefisaverLogger(DEFISAVER_LOGGER);
    modifier onlyApproved() {
        require(BotRegistry(BOT_REGISTRY_ADDRESS).botList(msg.sender), "Not auth bot");
        _;
    }
    constructor(address _aaveMonitorProxy, address _subscriptions, address _aaveSaverProxy) public {
        aaveMonitorProxy = AaveMonitorProxy(_aaveMonitorProxy);
        subscriptionsContract = AaveSubscriptions(_subscriptions);
        aaveSaverProxy = _aaveSaverProxy;
    }
    function repayFor(
        SaverExchangeCore.ExchangeData memory _exData,
        address _user
    ) public payable onlyApproved burnGas(REPAY_GAS_TOKEN) {
        (bool isAllowed, uint ratioBefore) = canCall(Method.Repay, _user);
        require(isAllowed);  
        uint256 gasCost = calcGasCost(REPAY_GAS_COST);
        aaveMonitorProxy.callExecute{value: msg.value}(
            _user,
            aaveSaverProxy,
            abi.encodeWithSignature(
                "repay((address,address,uint256,uint256,uint256,address,address,bytes,uint256),uint256)",
                _exData,
                gasCost
            )
        );
        (bool isGoodRatio, uint ratioAfter) = ratioGoodAfter(Method.Repay, _user);
        require(isGoodRatio);  
        returnEth();
        logger.Log(address(this), _user, "AutomaticAaveRepay", abi.encode(ratioBefore, ratioAfter));
    }
    function boostFor(
        SaverExchangeCore.ExchangeData memory _exData,
        address _user
    ) public payable onlyApproved burnGas(BOOST_GAS_TOKEN) {
        (bool isAllowed, uint ratioBefore) = canCall(Method.Boost, _user);
        require(isAllowed);  
        uint256 gasCost = calcGasCost(BOOST_GAS_COST);
        aaveMonitorProxy.callExecute{value: msg.value}(
            _user,
            aaveSaverProxy,
            abi.encodeWithSignature(
                "boost((address,address,uint256,uint256,uint256,address,address,bytes,uint256),uint256)",
                _exData,
                gasCost
            )
        );
        (bool isGoodRatio, uint ratioAfter) = ratioGoodAfter(Method.Boost, _user);
        require(isGoodRatio);   
        returnEth();
        logger.Log(address(this), _user, "AutomaticAaveBoost", abi.encode(ratioBefore, ratioAfter));
    }
    function returnEth() internal {
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }
    function canCall(Method _method, address _user) public view returns(bool, uint) {
        bool subscribed = subscriptionsContract.isSubscribed(_user);
        AaveSubscriptions.AaveHolder memory holder = subscriptionsContract.getHolder(_user);
        if (!subscribed) return (false, 0);
        if (_method == Method.Boost && !holder.boostEnabled) return (false, 0);
        uint currRatio = getSafetyRatio(_user);
        if (_method == Method.Repay) {
            return (currRatio < holder.minRatio, currRatio);
        } else if (_method == Method.Boost) {
            return (currRatio > holder.maxRatio, currRatio);
        }
    }
    function ratioGoodAfter(Method _method, address _user) public view returns(bool, uint) {
        AaveSubscriptions.AaveHolder memory holder;
        holder= subscriptionsContract.getHolder(_user);
        uint currRatio = getSafetyRatio(_user);
        if (_method == Method.Repay) {
            return (currRatio < holder.maxRatio, currRatio);
        } else if (_method == Method.Boost) {
            return (currRatio > holder.minRatio, currRatio);
        }
    }
    function calcGasCost(uint _gasAmount) public view returns (uint) {
        uint gasPrice = tx.gasprice <= MAX_GAS_PRICE ? tx.gasprice : MAX_GAS_PRICE;
        return mul(gasPrice, _gasAmount);
    }
    function changeAaveSaverProxy(address _newAaveSaverProxy) public onlyAdmin {
        aaveSaverProxy = _newAaveSaverProxy;
    }
    function changeBoostGasCost(uint _gasCost) public onlyOwner {
        require(_gasCost < 3000000);
        BOOST_GAS_COST = _gasCost;
    }
    function changeRepayGasCost(uint _gasCost) public onlyOwner {
        require(_gasCost < 3000000);
        REPAY_GAS_COST = _gasCost;
    }
    function changeMaxGasPrice(uint _maxGasPrice) public onlyOwner {
        require(_maxGasPrice < 500000000000);
        MAX_GAS_PRICE = _maxGasPrice;
    }
    function changeGasTokenAmount(uint _gasTokenAmount, bool _repay) public onlyOwner {
        if (_repay) {
            REPAY_GAS_TOKEN = _gasTokenAmount;
        } else {
            BOOST_GAS_TOKEN = _gasTokenAmount;
        }
    }
}
