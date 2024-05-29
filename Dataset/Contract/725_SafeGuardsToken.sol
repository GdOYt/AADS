contract SafeGuardsToken is CappedToken {
    string constant public name = "SafeGuards Coin";
    string constant public symbol = "SGCT";
    uint constant public decimals = 18;
    address public canBurnAddress;
    mapping (address => bool) public frozenList;
    uint256 public frozenPauseTime = now + 180 days;
    uint256 public burnPausedTime = now + 180 days;
    constructor(address _canBurnAddress) CappedToken(61 * 1e6 * 1e18) public {
        require(_canBurnAddress != 0x0);
        canBurnAddress = _canBurnAddress;
    }
    event ChangeFrozenPause(uint256 newFrozenPauseTime);
    function mintFrozen(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        frozenList[_to] = true;
        return super.mint(_to, _amount);
    }
    function changeFrozenTime(uint256 _newFrozenPauseTime) onlyOwner public returns (bool) {
        require(_newFrozenPauseTime > now);
        frozenPauseTime = _newFrozenPauseTime;
        emit ChangeFrozenPause(_newFrozenPauseTime);
        return true;
    }
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    function transfer(address _to, uint _value) public returns (bool) {
        bytes memory empty;
        return transfer(_to, _value, empty);
    }
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        require(now > frozenPauseTime || !frozenList[msg.sender]);
        super.transfer(_to, _value);
        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            emit Transfer(msg.sender, _to, _value, _data);
        }
        return true;
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        bytes memory empty;
        return transferFrom(_from, _to, _value, empty);
    }
    function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool) {
        require(now > frozenPauseTime || !frozenList[msg.sender]);
        super.transferFrom(_from, _to, _value);
        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(_from, _value, _data);
        }
        emit Transfer(_from, _to, _value, _data);
        return true;
    }
    function isContract(address _addr) private view returns (bool) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length>0);
    }
    event Burn(address indexed burner, uint256 value);
    event ChangeBurnPause(uint256 newBurnPauseTime);
    function burn(uint256 _value) public {
        require(burnPausedTime < now || msg.sender == canBurnAddress);
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
    function changeBurnPausedTime(uint256 _newBurnPauseTime) onlyOwner public returns (bool) {
        require(_newBurnPauseTime > burnPausedTime);
        burnPausedTime = _newBurnPauseTime;
        emit ChangeBurnPause(_newBurnPauseTime);
        return true;
    }
}
