contract ServiceProvider {
    function info() constant public returns(string);
    function onPayment(address _from, uint _value, bytes _paymentData) public returns (bool);
    function onSubExecuted(uint subId) public returns (bool);
    function onSubNew(uint newSubId, uint offerId) public returns (bool);
    function onSubCanceled(uint subId, address caller) public returns (bool);
    function onSubUnHold(uint subId, address caller, bool isOnHold) public returns (bool);
    event OfferCreated(uint offerId,  bytes descriptor, address provider);
    event OfferUpdated(uint offerId,  bytes descriptor, uint oldExecCounter, address provider);
    event OfferCanceled(uint offerId, bytes descriptor, address provider);
    event OfferUnHold(uint offerId,   bytes descriptor, bool isOnHoldNow, address provider);
}  
