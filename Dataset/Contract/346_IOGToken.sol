contract IOGToken is StandardToken, Ownable, Pausable {
    event Burn(address indexed burner, uint256 amount);
    event AddressLocked(address indexed _owner, uint256 _expiry);
    string public constant name = "IOGToken";
    string public constant symbol = "IOG";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = 2200000000 * (10 ** uint256(decimals));
    mapping (address => uint256) public addressLocks;
    constructor(address[] addressList, uint256[] tokenAmountList, uint256[] lockedPeriodList) public {
        totalSupply_ = TOTAL_SUPPLY;
        balances[msg.sender] = TOTAL_SUPPLY;
        emit Transfer(0x0, msg.sender, TOTAL_SUPPLY);
        distribution(addressList, tokenAmountList, lockedPeriodList);
    }
    function distribution(address[] addressList, uint256[] tokenAmountList, uint256[] lockedPeriodList) onlyOwner internal {
        for (uint i = 0; i < addressList.length; i++) {
            uint256 lockedPeriod = lockedPeriodList[i];
            if (0 < lockedPeriod) {
                timeLock(addressList[i], tokenAmountList[i] * (10 ** uint256(decimals)), now + (lockedPeriod * 60 * 60 * 24));
            }
            else {
                transfer(addressList[i], tokenAmountList[i] * (10 ** uint256(decimals)));
            }
        }
    }
    modifier canTransfer(address _sender) {
        require(_sender != address(0));
        require(canTransferIfLocked(_sender));
        _;
    }
    function canTransferIfLocked(address _sender) internal view returns(bool) {
        if (0 == addressLocks[_sender])
            return true;
        return (now >= addressLocks[_sender]);
    }
    function timeLock(address _to, uint256 _value, uint256 releaseDate) onlyOwner public {
        addressLocks[_to] = releaseDate;
        transfer(_to, _value);
        emit AddressLocked(_to, _value);
    }
    function transfer(address _to, uint256 _value) canTransfer(msg.sender) whenNotPaused public returns (bool success) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from) whenNotPaused public returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
        return super.approve(_spender, _value);
    }
    function increaseApproval(address _spender, uint _addedValue) whenNotPaused public returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }
    function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused public returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    function emergencyERC20Drain(ERC20 token, uint256 amount) external onlyOwner {
        token.transfer(owner, amount);
    }
}
