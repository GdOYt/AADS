contract ESportsToken is ESportsConstants, MintableToken {
    using SafeMath for uint;
    event Burn(address indexed burner, uint value);
    event MintTimelocked(address indexed beneficiary, uint amount);
    bool public paused = true;
    mapping(address => bool) excluded;
    mapping (address => ESportsFreezingStorage[]) public frozenFunds;
    function name() constant public returns (string _name) {
        return "ESports Token";
    }
    function symbol() constant public returns (string _symbol) {
        return "ERT";
    }
    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }
    function allowMoveTokens() onlyOwner {
        paused = false;
    }
    function addExcluded(address _toExclude) onlyOwner {
        addExcludedInternal(_toExclude);
    }
    function addExcludedInternal(address _toExclude) private {
        excluded[_toExclude] = true;
    }
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        require(!paused || excluded[_from]);
        return super.transferFrom(_from, _to, _value);
    }
    function transfer(address _to, uint _value) returns (bool) {
        require(!paused || excluded[msg.sender]);
        return super.transfer(_to, _value);
    }
    function mintTimelocked(address _to, uint _amount, uint32 _releaseTime)
            onlyOwner canMint returns (ESportsFreezingStorage) {
        ESportsFreezingStorage timelock = new ESportsFreezingStorage(this, _releaseTime);
        mint(timelock, _amount);
        frozenFunds[_to].push(timelock);
        addExcludedInternal(timelock);
        MintTimelocked(_to, _amount);
        return timelock;
    }
    function returnFrozenFreeFunds() public returns (uint) {
        uint total = 0;
        ESportsFreezingStorage[] storage frozenStorages = frozenFunds[msg.sender];
        for (uint x = 0; x < frozenStorages.length; x++) {
            uint amount = frozenStorages[x].release(msg.sender);
            total = total.add(amount);
        }
        return total;
    }
    function burn(uint _value) public {
        require(!paused || excluded[msg.sender]);
        require(_value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
    }
}
