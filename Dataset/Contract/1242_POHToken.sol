contract POHToken is StandardToken{
    uint  currUnlockStep;  
    uint256 currUnlockSeq;  
    mapping (uint => uint256[]) public freezeOf;  
    mapping (uint => bool) public stepUnlockInfo;  
    mapping (address => uint256) public freezeOfUser;  
    uint256 internal constant INITIAL_SUPPLY = 10 * (10**8) * (10 **18);
    event Burn(address indexed burner, uint256 value);
    event Freeze(address indexed locker, uint256 value);
    event Unfreeze(address indexed unlocker, uint256 value);
    event TransferMulti(uint256 count, uint256 total);
    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = INITIAL_SUPPLY;
        totalSupply = INITIAL_SUPPLY;
    }
    function transferAndLock(address _to, uint256 _value, uint256 _lockValue, uint _step) transable public returns (bool success) {
        require(_to != 0x0);
        require(_value <= balanceOf[msg.sender]);
        require(_value > 0);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        freeze(_to, _lockValue, _step);
        return true;
    }
    function transferFromAndLock(address _from, address _to, uint256 _value, uint256 _lockValue, uint _step) transable public returns (bool success) {
        uint256 _allowance = allowance[_from][msg.sender];
        require (_value <= _allowance);
        require(_to != 0x0);
        require(_value <= balanceOf[_from]);
        require(_value > 0);
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        freeze(_to, _lockValue, _step);
        return true;
    }
    function transferMulti(address[] _to, uint256[] _value) transable public returns (uint256 amount){
        require(_to.length == _value.length && _to.length <= 1024);
        uint256 balanceOfSender = balanceOf[msg.sender];
        uint256 len = _to.length;
        for(uint256 j; j<len; j++){
            require(_value[j] <= balanceOfSender);  
            require(amount <= balanceOfSender);
            amount += _value[j];
        }
        require(balanceOfSender >= amount);  
        balanceOf[msg.sender] -= amount;
        for(uint256 i; i<len; i++){
            address _toI = _to[i];
            uint256 _valueI = _value[i];
            balanceOf[_toI] += _valueI;
            emit Transfer(msg.sender, _toI, _valueI);
        }
        emit TransferMulti(len, amount);
    }
    function transferMultiSameVaule(address[] _to, uint256 _value) transable public returns (bool success){
        uint256 len = _to.length;
        uint256 amount = _value*len;
        require(amount <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= amount;  
        for(uint256 i; i<len; i++){
            address _toI = _to[i];
            balanceOf[_toI] += _value;
            emit Transfer(msg.sender, _toI, _value);
        }
        emit TransferMulti(len, amount);
        return true;
    }
    function freeze(address _user, uint256 _value, uint _step) internal returns (bool success) {
        require(balanceOf[_user] >= _value);
        balanceOf[_user] -= _value;
        freezeOfUser[_user] += _value;
        freezeOf[_step].push(uint256(_user)<<92|_value);
        emit Freeze(_user, _value);
        return true;
    }
    function unFreeze(uint _step) onlyOwner public returns (bool unlockOver) {
        require(currUnlockStep==_step || currUnlockSeq==uint256(0));
        require(stepUnlockInfo[_step]==false);
        uint256[] memory currArr = freezeOf[_step];
        currUnlockStep = _step;
        if(currUnlockSeq==uint256(0)){
            currUnlockSeq = currArr.length;
        }
        uint256 userLockInfo;
        uint256 _amount;
        address userAddress;
        for(uint i = 0; i<99&&currUnlockSeq>0; i++){
            userLockInfo = freezeOf[_step][currUnlockSeq-1];
            _amount = userLockInfo&0xFFFFFFFFFFFFFFFFFFFFFFF;
            userAddress = address(userLockInfo>>92);
            balanceOf[userAddress] += _amount;
            freezeOfUser[userAddress] -= _amount;
            emit Unfreeze(userAddress, _amount);
            currUnlockSeq--;
        }
        if(currUnlockSeq==0){
            stepUnlockInfo[_step] = true;
        }
        return true;
    }
    function burn(uint256 _value) transable public returns (bool success) {
        require(_value > 0);
        require(_value <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
    function enableTransfers(bool _transfersEnabled) onlyOwner public {
      transfersEnabled = _transfersEnabled;
    }
    address public owner;
    event ChangeOwner(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    function claim() onlyOwner public {
      owner.transfer(this.balance);
    }
    function changeOwner(address newOwner) onlyOwner public {
      require(newOwner != address(0));
      owner = newOwner;
      emit ChangeOwner(owner, newOwner);
    }
}
