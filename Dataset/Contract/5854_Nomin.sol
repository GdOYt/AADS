contract Nomin is FeeToken {
    Court public court;
    Havven public havven;
    mapping(address => bool) public frozen;
    uint constant TRANSFER_FEE_RATE = 15 * UNIT / 10000;
    string constant TOKEN_NAME = "Nomin USD";
    string constant TOKEN_SYMBOL = "nUSD";
    constructor(address _proxy, TokenState _tokenState, Havven _havven,
                uint _totalSupply,
                address _owner)
        FeeToken(_proxy, _tokenState,
                 TOKEN_NAME, TOKEN_SYMBOL, _totalSupply,
                 TRANSFER_FEE_RATE,
                 _havven,  
                 _owner)
        public
    {
        require(_proxy != 0 && address(_havven) != 0 && _owner != 0);
        frozen[FEE_ADDRESS] = true;
        havven = _havven;
    }
    function setCourt(Court _court)
        external
        optionalProxy_onlyOwner
    {
        court = _court;
        emitCourtUpdated(_court);
    }
    function setHavven(Havven _havven)
        external
        optionalProxy_onlyOwner
    {
        havven = _havven;
        setFeeAuthority(_havven);
        emitHavvenUpdated(_havven);
    }
    function transfer(address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transfer_byProxy(messageSender, to, value);
    }
    function transferFrom(address from, address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferFrom_byProxy(messageSender, from, to, value);
    }
    function transferSenderPaysFee(address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferSenderPaysFee_byProxy(messageSender, to, value);
    }
    function transferFromSenderPaysFee(address from, address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferFromSenderPaysFee_byProxy(messageSender, from, to, value);
    }
    function freezeAndConfiscate(address target)
        external
        onlyCourt
    {
        uint motionID = court.targetMotionID(target);
        require(motionID != 0);
        require(court.motionConfirming(motionID));
        require(court.motionPasses(motionID));
        require(!frozen[target]);
        uint balance = tokenState.balanceOf(target);
        tokenState.setBalanceOf(FEE_ADDRESS, safeAdd(tokenState.balanceOf(FEE_ADDRESS), balance));
        tokenState.setBalanceOf(target, 0);
        frozen[target] = true;
        emitAccountFrozen(target, balance);
        emitTransfer(target, FEE_ADDRESS, balance);
    }
    function unfreezeAccount(address target)
        external
        optionalProxy_onlyOwner
    {
        require(frozen[target] && target != FEE_ADDRESS);
        frozen[target] = false;
        emitAccountUnfrozen(target);
    }
    function issue(address account, uint amount)
        external
        onlyHavven
    {
        tokenState.setBalanceOf(account, safeAdd(tokenState.balanceOf(account), amount));
        totalSupply = safeAdd(totalSupply, amount);
        emitTransfer(address(0), account, amount);
        emitIssued(account, amount);
    }
    function burn(address account, uint amount)
        external
        onlyHavven
    {
        tokenState.setBalanceOf(account, safeSub(tokenState.balanceOf(account), amount));
        totalSupply = safeSub(totalSupply, amount);
        emitTransfer(account, address(0), amount);
        emitBurned(account, amount);
    }
    modifier onlyHavven() {
        require(Havven(msg.sender) == havven);
        _;
    }
    modifier onlyCourt() {
        require(Court(msg.sender) == court);
        _;
    }
    event CourtUpdated(address newCourt);
    bytes32 constant COURTUPDATED_SIG = keccak256("CourtUpdated(address)");
    function emitCourtUpdated(address newCourt) internal {
        proxy._emit(abi.encode(newCourt), 1, COURTUPDATED_SIG, 0, 0, 0);
    }
    event HavvenUpdated(address newHavven);
    bytes32 constant HAVVENUPDATED_SIG = keccak256("HavvenUpdated(address)");
    function emitHavvenUpdated(address newHavven) internal {
        proxy._emit(abi.encode(newHavven), 1, HAVVENUPDATED_SIG, 0, 0, 0);
    }
    event AccountFrozen(address indexed target, uint balance);
    bytes32 constant ACCOUNTFROZEN_SIG = keccak256("AccountFrozen(address,uint256)");
    function emitAccountFrozen(address target, uint balance) internal {
        proxy._emit(abi.encode(balance), 2, ACCOUNTFROZEN_SIG, bytes32(target), 0, 0);
    }
    event AccountUnfrozen(address indexed target);
    bytes32 constant ACCOUNTUNFROZEN_SIG = keccak256("AccountUnfrozen(address)");
    function emitAccountUnfrozen(address target) internal {
        proxy._emit(abi.encode(), 2, ACCOUNTUNFROZEN_SIG, bytes32(target), 0, 0);
    }
    event Issued(address indexed account, uint amount);
    bytes32 constant ISSUED_SIG = keccak256("Issued(address,uint256)");
    function emitIssued(address account, uint amount) internal {
        proxy._emit(abi.encode(amount), 2, ISSUED_SIG, bytes32(account), 0, 0);
    }
    event Burned(address indexed account, uint amount);
    bytes32 constant BURNED_SIG = keccak256("Burned(address,uint256)");
    function emitBurned(address account, uint amount) internal {
        proxy._emit(abi.encode(amount), 2, BURNED_SIG, bytes32(account), 0, 0);
    }
}
