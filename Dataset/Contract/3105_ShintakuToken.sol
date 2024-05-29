contract ShintakuToken is BaseToken, Ownable {
    using SafeMath for uint;
    string public constant symbol = "SHN";
    string public constant name = "Shintaku";
    uint8 public constant demicals = 18;
    uint public constant TOKEN_UNIT = (10 ** uint(demicals));
    uint public PERIOD_BLOCKS;
    uint public OWNER_LOCK_BLOCKS;
    uint public USER_LOCK_BLOCKS;
    uint public constant TAIL_EMISSION = 400 * (10 ** 3) * TOKEN_UNIT;
    uint public constant INITIAL_EMISSION_FACTOR = 25;
    uint public constant MAX_RECEIVED_PER_PERIOD = 10000 ether;
    struct Period {
        uint started;
        uint totalReceived;
        uint ownerLockedBalance;
        uint minting;
        mapping (address => bytes32) sealedPurchaseOrders;
        mapping (address => uint) receivedBalances;
        mapping (address => uint) lockedBalances;
        mapping (address => address) aliases;
    }
    modifier validPeriod(uint _period) {
        require(_period <= currentPeriodIndex());
        _;
    }
    Period[] internal periods;
    address public ownerAlias;
    event NextPeriod(uint indexed _period, uint indexed _block);
    event SealedOrderPlaced(address indexed _from, uint indexed _period, uint _value);
    event SealedOrderRevealed(address indexed _from, uint indexed _period, address indexed _alias, uint _value);
    event OpenOrderPlaced(address indexed _from, uint indexed _period, address indexed _alias, uint _value);
    event Claimed(address indexed _from, uint indexed _period, address indexed _alias, uint _value);
    constructor(address _alias, uint _periodBlocks, uint _ownerLockFactor, uint _userLockFactor) public {
        require(_alias != address(0));
        require(_periodBlocks >= 2);
        require(_ownerLockFactor > 0);
        require(_userLockFactor > 0);
        periods.push(Period(block.number, 0, 0, calculateMinting(0)));
        ownerAlias = _alias;
        PERIOD_BLOCKS = _periodBlocks;
        OWNER_LOCK_BLOCKS = _periodBlocks.mul(_ownerLockFactor);
        USER_LOCK_BLOCKS = _periodBlocks.mul(_userLockFactor);
    }
    function nextPeriod() public {
        uint periodIndex = currentPeriodIndex();
        uint periodIndexNext = periodIndex.add(1);
        require(block.number.sub(periods[periodIndex].started) > PERIOD_BLOCKS);
        periods.push(Period(block.number, 0, 0, calculateMinting(periodIndexNext)));
        emit NextPeriod(periodIndexNext, block.number);
    }
    function createPurchaseOrder(address _from, uint _period, uint _value, bytes32 _salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_from, _period, _value, _salt));
    }
    function placePurchaseOrder(bytes32 _sealedPurchaseOrder) public payable {
        if (block.number.sub(periods[currentPeriodIndex()].started) > PERIOD_BLOCKS) {
            nextPeriod();
        }
        Period storage period = periods[currentPeriodIndex()];
        require(period.sealedPurchaseOrders[msg.sender] == bytes32(0));
        period.sealedPurchaseOrders[msg.sender] = _sealedPurchaseOrder;
        period.receivedBalances[msg.sender] = msg.value;
        emit SealedOrderPlaced(msg.sender, currentPeriodIndex(), msg.value);
    }
    function revealPurchaseOrder(bytes32 _sealedPurchaseOrder, uint _period, uint _value, bytes32 _salt, address _alias) public {
        require(_alias != address(0));
        require(currentPeriodIndex() == _period.add(1));
        Period storage period = periods[_period];
        require(period.aliases[msg.sender] == address(0));
        bytes32 h = createPurchaseOrder(msg.sender, _period, _value, _salt);
        require(h == _sealedPurchaseOrder);
        require(_value <= period.receivedBalances[msg.sender]);
        period.totalReceived = period.totalReceived.add(_value);
        uint remainder = period.receivedBalances[msg.sender].sub(_value);
        period.receivedBalances[msg.sender] = _value;
        period.aliases[msg.sender] = _alias;
        emit SealedOrderRevealed(msg.sender, _period, _alias, _value);
        _alias.transfer(remainder);
    }
    function placeOpenPurchaseOrder(address _alias) public payable {
        require(_alias != address(0));
        if (block.number.sub(periods[currentPeriodIndex()].started) > PERIOD_BLOCKS) {
            nextPeriod();
        }
        Period storage period = periods[currentPeriodIndex()];
        require(period.aliases[msg.sender] == address(0));
        period.totalReceived = period.totalReceived.add(msg.value);
        period.receivedBalances[msg.sender] = msg.value;
        period.aliases[msg.sender] = _alias;
        emit OpenOrderPlaced(msg.sender, currentPeriodIndex(), _alias, msg.value);
    }
    function claim(address _from, uint _period) public {
        require(currentPeriodIndex() > _period.add(1));
        Period storage period = periods[_period];
        require(period.receivedBalances[_from] > 0);
        uint value = period.receivedBalances[_from];
        delete period.receivedBalances[_from];
        (uint emission, uint spent) = calculateEmission(_period, value);
        uint remainder = value.sub(spent);
        address alias = period.aliases[_from];
        mint(alias, emission);
        period.lockedBalances[_from] = period.lockedBalances[_from].add(remainder);
        period.ownerLockedBalance = period.ownerLockedBalance.add(spent);
        emit Claimed(_from, _period, alias, emission);
    }
    function withdraw(address _from, uint _period) public {
        require(currentPeriodIndex() > _period);
        Period storage period = periods[_period];
        require(block.number.sub(period.started) > USER_LOCK_BLOCKS);
        uint balance = period.lockedBalances[_from];
        require(balance <= address(this).balance);
        delete period.lockedBalances[_from];
        address alias = period.aliases[_from];
        alias.transfer(balance);
    }
    function withdrawOwner(uint _period) public onlyOwner {
        require(currentPeriodIndex() > _period);
        Period storage period = periods[_period];
        require(block.number.sub(period.started) > OWNER_LOCK_BLOCKS);
        uint balance = period.ownerLockedBalance;
        require(balance <= address(this).balance);
        delete period.ownerLockedBalance;
        ownerAlias.transfer(balance);
    }
    function withdrawOwnerUnrevealed(uint _period, address _from) public onlyOwner {
        require(currentPeriodIndex() > _period.add(1));
        Period storage period = periods[_period];
        require(block.number.sub(period.started) > OWNER_LOCK_BLOCKS);
        uint balance = period.receivedBalances[_from];
        require(balance <= address(this).balance);
        delete period.receivedBalances[_from];
        ownerAlias.transfer(balance);
    }
    function calculateMinting(uint _period) internal pure returns (uint) {
        return
            _period < INITIAL_EMISSION_FACTOR ?
            TAIL_EMISSION.mul(INITIAL_EMISSION_FACTOR.sub(_period)) :
            TAIL_EMISSION
        ;
    }
    function currentPeriodIndex() public view returns (uint) {
        assert(periods.length > 0);
        return periods.length.sub(1);
    }
    function calculateEmission(uint _period, uint _value) internal view returns (uint, uint) {
        Period storage currentPeriod = periods[_period];
        uint minting = currentPeriod.minting;
        uint totalReceived = currentPeriod.totalReceived;
        uint scaledValue = _value;
        if (totalReceived > MAX_RECEIVED_PER_PERIOD) {
            scaledValue = _value.mul(MAX_RECEIVED_PER_PERIOD).div(totalReceived);
        }
        uint emission = scaledValue.mul(minting).div(MAX_RECEIVED_PER_PERIOD);
        return (emission, scaledValue);
    }
    function mint(address _account, uint _value) internal {
        balances[_account] = balances[_account].add(_value);
        totalSupply_ = totalSupply_.add(_value);
    }
    function getPeriodStarted(uint _period) public view validPeriod(_period) returns (uint) {
        return periods[_period].started;
    }
    function getPeriodTotalReceived(uint _period) public view validPeriod(_period) returns (uint) {
        return periods[_period].totalReceived;
    }
    function getPeriodOwnerLockedBalance(uint _period) public view validPeriod(_period) returns (uint) {
        return periods[_period].ownerLockedBalance;
    }
    function getPeriodMinting(uint _period) public view validPeriod(_period) returns (uint) {
        return periods[_period].minting;
    }
    function getPeriodSealedPurchaseOrderFor(uint _period, address _account) public view validPeriod(_period) returns (bytes32) {
        return periods[_period].sealedPurchaseOrders[_account];
    }
    function getPeriodReceivedBalanceFor(uint _period, address _account) public view validPeriod(_period) returns (uint) {
        return periods[_period].receivedBalances[_account];
    }
    function getPeriodLockedBalanceFor(uint _period, address _account) public view validPeriod(_period) returns (uint) {
        return periods[_period].lockedBalances[_account];
    }
    function getPeriodAliasFor(uint _period, address _account) public view validPeriod(_period) returns (address) {
        return periods[_period].aliases[_account];
    }
}
