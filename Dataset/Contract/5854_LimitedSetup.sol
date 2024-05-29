contract LimitedSetup {
    uint setupExpiryTime;
    constructor(uint setupDuration)
        public
    {
        setupExpiryTime = now + setupDuration;
    }
    modifier onlyDuringSetup
    {
        require(now < setupExpiryTime);
        _;
    }
}
