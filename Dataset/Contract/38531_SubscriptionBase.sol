contract SubscriptionBase {
    enum SubState   {NOT_EXIST, BEFORE_START, PAID, CHARGEABLE, ON_HOLD, CANCELED, EXPIRED, FINALIZED}
    enum OfferState {NOT_EXIST, BEFORE_START, ACTIVE, SOLD_OUT, ON_HOLD, EXPIRED}
    string[] internal SUB_STATES   = ["NOT_EXIST", "BEFORE_START", "PAID", "CHARGEABLE", "ON_HOLD", "CANCELED", "EXPIRED", "FINALIZED" ];
    string[] internal OFFER_STATES = ["NOT_EXIST", "BEFORE_START", "ACTIVE", "SOLD_OUT", "ON_HOLD", "EXPIRED"];
    struct Subscription {
        address transferFrom;    
        address transferTo;      
        uint pricePerHour;       
        uint32 initialXrate_n;   
        uint32 initialXrate_d;   
        uint16 xrateProviderId;  
        uint paidUntil;          
        uint chargePeriod;       
        uint depositAmount;      
        uint startOn;            
        uint expireOn;           
        uint execCounter;        
        bytes descriptor;        
        uint onHoldSince;        
    }
    struct Deposit {
        uint value;          
        address owner;       
        uint createdOn;      
        uint lockTime;       
        bytes descriptor;    
    }
    event NewSubscription(address customer, address service, uint offerId, uint subId);
    event NewDeposit(uint depositId, uint value, uint lockTime, address sender);
    event NewXRateProvider(address addr, uint16 xRateProviderId, address sender);
    event DepositReturned(uint depositId, address returnedTo);
    event SubscriptionDepositReturned(uint subId, uint amount, address returnedTo, address sender);
    event OfferOnHold(uint offerId, bool onHold, address sender);
    event OfferCanceled(uint offerId, address sender);
    event SubOnHold(uint offerId, bool onHold, address sender);
    event SubCanceled(uint subId, address sender);
    event SubModuleSuspended(uint suspendUntil);
}
