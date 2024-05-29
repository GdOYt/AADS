contract SubscriptionModuleImpl is SubscriptionModule, Owned  {
    string public constant VERSION = "0.1.0";
    mapping (address=>bool) public providerRegistry;
    mapping (uint => Subscription) public subscriptions;
    mapping (uint => Deposit) public deposits;
    XRateProvider[] public xrateProviders;
    uint public subscriptionCounter = 0;
    uint public depositCounter = 0;
    ERC20ModuleSupport public san;
    function () {
        throw;
    }
    function SubscriptionModuleImpl() {
        owner = msg.sender;
        xrateProviders.push(XRateProvider(this));  
    }
    function attachToken(address token) public {
        assert(address(san) == 0);  
        san = ERC20ModuleSupport(token);
    }
    function enableServiceProvider(ServiceProvider addr, bytes moreInfo) public only(owner) {
        providerRegistry[addr] = true;
        ServiceProviderEnabled(addr, moreInfo);
    }
    function disableServiceProvider(ServiceProvider addr, bytes moreInfo) public only(owner) {
        delete providerRegistry[addr];
        ServiceProviderDisabled(addr, moreInfo);
    }
    function registerXRateProvider(XRateProvider addr) public only(owner) returns (uint16 xrateProviderId) {
        xrateProviderId = uint16(xrateProviders.length);
        xrateProviders.push(addr);
        NewXRateProvider(addr, xrateProviderId, msg.sender);
    }
    function getXRateProviderLength() public constant returns (uint) {
        return xrateProviders.length;
    }
    function paymentTo(uint _value, bytes _paymentData, ServiceProvider _to) public reentrant returns (bool success) {
        if (san._fulfillPayment(msg.sender, _to, _value, 0, msg.sender)) {
            assert (ServiceProvider(_to).onPayment(msg.sender, _value, _paymentData));                       
            return true;
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function paymentFrom(uint _value, bytes _paymentData, address _from, ServiceProvider _to) public reentrant returns (bool success) {
        if (san._fulfillPreapprovedPayment(_from, _to, _value, msg.sender)) {
            assert (ServiceProvider(_to).onPayment(_from, _value, _paymentData));                            
            return true;
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function subscriptionDetails(uint subId) public constant returns (
        address transferFrom,
        address transferTo,
        uint pricePerHour,
        uint32 initialXrate_n,  
        uint32 initialXrate_d,  
        uint16 xrateProviderId,
        uint chargePeriod,
        uint startOn,
        bytes descriptor
    ) {
        Subscription sub = subscriptions[subId];
        return (sub.transferFrom, sub.transferTo, sub.pricePerHour, sub.initialXrate_n, sub.initialXrate_d, sub.xrateProviderId, sub.chargePeriod, sub.startOn, sub.descriptor);
    }
    function subscriptionStatus(uint subId) public constant returns(
        uint depositAmount,
        uint expireOn,
        uint execCounter,
        uint paidUntil,
        uint onHoldSince
    ) {
        Subscription sub = subscriptions[subId];
        return (sub.depositAmount, sub.expireOn, sub.execCounter, sub.paidUntil, sub.onHoldSince);
    }
    function executeSubscription(uint subId) public noReentrancy(L00) returns (bool) {
        Subscription storage sub = subscriptions[subId];
        assert (msg.sender == sub.transferFrom || msg.sender == sub.transferTo || msg.sender == owner);
        if (_subscriptionState(sub)==SubState.CHARGEABLE) {
            var _from = sub.transferFrom;
            var _to = sub.transferTo;
            var _value = _amountToCharge(sub);
            if (san._fulfillPayment(_from, _to, _value, subId, msg.sender)) {
                sub.paidUntil  = max(sub.paidUntil, sub.startOn) + sub.chargePeriod;
                ++sub.execCounter;
                assert (ServiceProvider(_to).onSubExecuted(subId));
                return true;
            }
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function postponeDueDate(uint subId, uint newDueDate) public returns (bool success){
        Subscription storage sub = subscriptions[subId];
        assert (_isSubscription(sub));
        assert (sub.transferTo == msg.sender);  
        if (sub.paidUntil < newDueDate) {
            sub.paidUntil = newDueDate;
            return true;
        } else if (isContract(msg.sender)) { return false; }
          else { throw; }
    }
    function state(uint subOrOfferId) public constant returns(string state) {
        Subscription subOrOffer = subscriptions[subOrOfferId];
        return _isOffer(subOrOffer)
              ? OFFER_STATES[uint(_offerState(subOrOffer))]
              : SUB_STATES[uint(_subscriptionState(subOrOffer))];
    }
    function stateCode(uint subOrOfferId) public constant returns(uint stateCode) {
        Subscription subOrOffer = subscriptions[subOrOfferId];
        return _isOffer(subOrOffer)
              ? uint(_offerState(subOrOffer))
              : uint(_subscriptionState(subOrOffer));
    }
    function _offerState(Subscription storage sub) internal constant returns(OfferState status) {
        if (!_isOffer(sub)) {
            return OfferState.NOT_EXIST;
        } else if (sub.startOn > now) {
            return OfferState.BEFORE_START;
        } else if (sub.onHoldSince > 0) {
            return OfferState.ON_HOLD;
        } else if (now <= sub.expireOn) {
            return sub.execCounter > 0
                ? OfferState.ACTIVE
                : OfferState.SOLD_OUT;
        } else {
            return OfferState.EXPIRED;
        }
    }
    function _subscriptionState(Subscription storage sub) internal constant returns(SubState status) {
        if (!_isSubscription(sub)) {
            return SubState.NOT_EXIST;
        } else if (sub.startOn > now) {
            return SubState.BEFORE_START;
        } else if (sub.onHoldSince > 0) {
            return SubState.ON_HOLD;
        } else if (sub.paidUntil >= sub.expireOn) {
            return now < sub.expireOn
                ? SubState.CANCELED
                : sub.depositAmount > 0
                    ? SubState.EXPIRED
                    : SubState.FINALIZED;
        } else if (sub.paidUntil <= now) {
            return SubState.CHARGEABLE;
        } else {
            return SubState.PAID;
        }
    }
    function createSubscriptionOffer(uint _pricePerHour, uint16 _xrateProviderId, uint _chargePeriod, uint _expireOn, uint _offerLimit, uint _depositAmount, uint _startOn, bytes _descriptor)
    public
    noReentrancy(L01)
    onlyRegisteredProvider
    returns (uint subId) {
        assert (_startOn < _expireOn);
        assert (_chargePeriod <= 10 years);  
        var (_xrate_n, _xrate_d) = _xrateProviderId == 0
                                 ? (1,1)
                                 : XRateProvider(xrateProviders[_xrateProviderId]).getRate();  
        assert (_xrate_n > 0 && _xrate_d > 0);
        subscriptions[++subscriptionCounter] = Subscription ({
            transferFrom    : 0,                   
            transferTo      : msg.sender,          
            pricePerHour    : _pricePerHour,       
            xrateProviderId : _xrateProviderId,    
            initialXrate_n  : _xrate_n,            
            initialXrate_d  : _xrate_d,            
            paidUntil       : 0,                   
            chargePeriod    : _chargePeriod,       
            depositAmount   : _depositAmount,      
            startOn         : _startOn,
            expireOn        : _expireOn,
            execCounter     : _offerLimit,
            descriptor      : _descriptor,
            onHoldSince     : 0                    
        });
        return subscriptionCounter;                
    }
    function updateSubscriptionOffer(uint _offerId, uint _offerLimit) public {
        Subscription storage offer = subscriptions[_offerId];
        assert (_isOffer(offer));
        assert (offer.transferTo == msg.sender);  
        offer.execCounter = _offerLimit;
    }
    function createSubscription(uint _offerId, uint _expireOn, uint _startOn) public noReentrancy(L02) returns (uint newSubId) {
        assert (_startOn < _expireOn);
        Subscription storage offer = subscriptions[_offerId];
        assert (_isOffer(offer));
        assert (offer.startOn == 0     || offer.startOn  <= now);
        assert (offer.expireOn == 0    || offer.expireOn >= now);
        assert (offer.onHoldSince == 0);
        assert (offer.execCounter > 0);
        --offer.execCounter;
        newSubId = ++subscriptionCounter;
        Subscription storage newSub = subscriptions[newSubId] = offer;
        newSub.transferFrom = msg.sender;
        newSub.execCounter = 0;
        newSub.paidUntil = newSub.startOn = max(_startOn, now);      
        newSub.expireOn = _expireOn;
        newSub.depositAmount = _applyXchangeRate(newSub.depositAmount, newSub);                     
        assert (san._burnForDeposit(msg.sender, newSub.depositAmount));
        assert (ServiceProvider(newSub.transferTo).onSubNew(newSubId, _offerId));                   
        NewSubscription(newSub.transferFrom, newSub.transferTo, _offerId, newSubId);
        return newSubId;
    }
    function cancelSubscriptionOffer(uint offerId) public returns (bool) {
        Subscription storage offer = subscriptions[offerId];
        assert (_isOffer(offer));
        assert (offer.transferTo == msg.sender || owner == msg.sender);  
        if (offer.expireOn>now){
            offer.expireOn = now;
            OfferCanceled(offerId, msg.sender);
            return true;
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function cancelSubscription(uint subId) public {
        return cancelSubscription(subId, 0);
    }
    function cancelSubscription(uint subId, uint gasReserve) public noReentrancy(L03) {
        Subscription storage sub = subscriptions[subId];
        assert (sub.transferFrom == msg.sender || owner == msg.sender);  
        assert (_isSubscription(sub));
        var _to = sub.transferTo;
        sub.expireOn = max(now, sub.paidUntil);
        if (msg.sender != _to) {
            gasReserve = max(gasReserve,10000);   
            assert (msg.gas > gasReserve);        
            if (_to.call.gas(msg.gas-gasReserve)(bytes4(sha3("onSubCanceled(uint256,address)")), subId, msg.sender)) {      
            }
        }
        SubCanceled(subId, msg.sender);
    }
    function holdSubscriptionOffer(uint offerId) public returns (bool success) {
        Subscription storage offer = subscriptions[offerId];
        assert (_isOffer(offer));
        require (msg.sender == offer.transferTo || msg.sender == owner);  
        if (offer.onHoldSince == 0) {
            offer.onHoldSince = now;
            OfferOnHold(offerId, true, msg.sender);
            return true;
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function unholdSubscriptionOffer(uint offerId) public returns (bool success) {
        Subscription storage offer = subscriptions[offerId];
        assert (_isOffer(offer));
        require (msg.sender == offer.transferTo || msg.sender == owner);  
        if (offer.onHoldSince > 0) {
            offer.onHoldSince = 0;
            OfferOnHold(offerId, false, msg.sender);
            return true;
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function holdSubscription(uint subId) public noReentrancy(L04) returns (bool success) {
        Subscription storage sub = subscriptions[subId];
        assert (_isSubscription(sub));
        var _to = sub.transferTo;
        require (msg.sender == _to || msg.sender == sub.transferFrom);  
        if (sub.onHoldSince == 0) {
            if (msg.sender == _to || ServiceProvider(_to).onSubUnHold(subId, msg.sender, true)) {           
                sub.onHoldSince = now;
                SubOnHold(subId, true, msg.sender);
                return true;
            }
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function unholdSubscription(uint subId) public noReentrancy(L05) returns (bool success) {
        Subscription storage sub = subscriptions[subId];
        assert (_isSubscription(sub));
        var _to = sub.transferTo;
        require (msg.sender == _to || msg.sender == sub.transferFrom);  
        if (sub.onHoldSince > 0) {
            if (msg.sender == _to || ServiceProvider(_to).onSubUnHold(subId, msg.sender, false)) {          
                sub.paidUntil += now - sub.onHoldSince;
                sub.onHoldSince = 0;
                SubOnHold(subId, false, msg.sender);
                return true;
            }
        }
        if (isContract(msg.sender)) { return false; }
        else { throw; }
    }
    function returnSubscriptionDesposit(uint subId) public {
        Subscription storage sub = subscriptions[subId];
        assert (_subscriptionState(sub) == SubState.CANCELED);
        assert (sub.depositAmount > 0);  
        assert (sub.transferTo == msg.sender || owner == msg.sender);  
        sub.expireOn = now;
        _returnSubscriptionDesposit(subId, sub);
    }
    function claimSubscriptionDeposit(uint subId) public {
        Subscription storage sub = subscriptions[subId];
        assert (_subscriptionState(sub) == SubState.EXPIRED);
        assert (sub.transferFrom == msg.sender);
        assert (sub.depositAmount > 0);
        _returnSubscriptionDesposit(subId, sub);
    }
    function _returnSubscriptionDesposit(uint subId, Subscription storage sub) internal {
        uint depositAmount = sub.depositAmount;
        sub.depositAmount = 0;
        san._mintFromDeposit(sub.transferFrom, depositAmount);
        SubscriptionDepositReturned(subId, depositAmount, sub.transferFrom, msg.sender);
    }
    function createDeposit(uint _value, bytes _descriptor) public returns (uint depositId) {
        require (_value > 0);
        assert (san._burnForDeposit(msg.sender,_value));
        deposits[++depositCounter] = Deposit ({
            owner : msg.sender,
            value : _value,
            descriptor : _descriptor
        });
        NewDeposit(depositCounter, _value, msg.sender);
        return depositCounter;
    }
    function claimDeposit(uint _depositId) public {
        var deposit = deposits[_depositId];
        require (deposit.owner == msg.sender);
        var value = deposits[_depositId].value;
        delete deposits[_depositId];
        san._mintFromDeposit(msg.sender, value);
        DepositReturned(_depositId, msg.sender);
    }
    function _amountToCharge(Subscription storage sub) internal reentrant returns (uint) {
        return _applyXchangeRate(sub.pricePerHour * sub.chargePeriod, sub) / 1 hours;        
    }
    function _applyXchangeRate(uint amount, Subscription storage sub) internal reentrant returns (uint) {   
        if (sub.xrateProviderId > 0) {
            var (xrate_n, xrate_d) = XRateProvider(xrateProviders[sub.xrateProviderId]).getRate();         
            amount = amount * sub.initialXrate_n * xrate_d / sub.initialXrate_d / xrate_n;
        }
        return amount;
    }
    function _isOffer(Subscription storage sub) internal constant returns (bool){
        return sub.transferFrom == 0 && sub.transferTo != 0;
    }
    function _isSubscription(Subscription storage sub) internal constant returns (bool){
        return sub.transferFrom != 0 && sub.transferTo != 0;
    }
    function _exists(Subscription storage sub) internal constant returns (bool){
        return sub.transferTo != 0;    
    }
    modifier onlyRegisteredProvider(){
        if (!providerRegistry[msg.sender]) throw;
        _;
    }
}  
