contract CSC {
    mapping (address => uint256) private balances;
    mapping (address => uint256[2]) private lockedBalances;
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    uint256 public totalSupply;
    address public owner;
        uint256 private icoLockUntil = 1543593540;
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        address _owner,
        address[] _lockedAddress,
        uint256[] _lockedBalances,
        uint256[] _lockedTimes
    ) public {
        balances[_owner] = _initialAmount;                    
        totalSupply = _initialAmount;                         
        name = _tokenName;                                    
        decimals = _decimalUnits;                             
        symbol = _tokenSymbol;                                
        owner = _owner;                                       
        for(uint i = 0;i < _lockedAddress.length;i++){
            lockedBalances[_lockedAddress[i]][0] = _lockedBalances[i];
            lockedBalances[_lockedAddress[i]][1] = _lockedTimes[i];
        }
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(msg.sender == owner || icoLockUntil < now);
        if(_to != address(0)){
            if(lockedBalances[msg.sender][1] >= now) {
                require((balances[msg.sender] > lockedBalances[msg.sender][0]) &&
                 (balances[msg.sender] - lockedBalances[msg.sender][0] >= _value));
            } else {
                require(balances[msg.sender] >= _value);
            }
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
    }
    function burnFrom(address _who,uint256 _value)public returns (bool){
        require(msg.sender == owner);
        assert(balances[_who] >= _value);
        totalSupply -= _value;
        balances[_who] -= _value;
        lockedBalances[_who][0] = 0;
        lockedBalances[_who][1] = 0;
        return true;
    }
    function makeCoin(uint256 _value)public returns (bool){
        require(msg.sender == owner);
        totalSupply += _value;
        balances[owner] += _value;
        return true;
    }
    function setIcoLockUntil(uint256 _until) public{
        require(msg.sender == owner);
        icoLockUntil = _until;
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    function withdraw() public{
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
    function withdrawTo(address _to) public{
        require(msg.sender == owner);
        address(_to).transfer(address(this).balance);
    }
}
