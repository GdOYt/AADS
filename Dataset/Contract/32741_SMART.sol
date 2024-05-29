contract SMART is StandardToken {
    function () public payable {
        require(msg.value > 0 && receivedWei < targetWei);
        require(now > releaseTime);
        receivedWei += msg.value;
        walletAddress.transfer(msg.value);
        NewSale(msg.sender, msg.value);
        assert(receivedWei >= msg.value);
    }
    string public name = "SmartMesh Token";                    
    uint8 public decimals = 18;                 
    string public symbol = "SMART";                  
    string public version = 'v0.1';        
    address public founder;  
    uint256 public targetWei; 
    uint256 public receivedWei; 
    uint256 public releaseTime; 
    uint256 public allocateEndTime;
    address public walletAddress; 
    event NewSale(address indexed _from, uint256 _amount);
    mapping(address => uint256) nonces;
    function SMART(address _walletAddress) public {
        founder = msg.sender;
        walletAddress = _walletAddress;
        releaseTime = 1511917200;
        allocateEndTime = releaseTime + 37 days;
        targetWei = 3900 ether;
    }
    function transferProxy(address _from, address _to, uint256 _value, uint256 _feeSmart,
        uint8 _v,bytes32 _r, bytes32 _s) public returns (bool){
        if(balances[_from] < _feeSmart + _value) revert();
        uint256 nonce = nonces[_from];
        bytes32 h = keccak256(_from,_to,_value,_feeSmart,nonce);
        if(_from != ecrecover(h,_v,_r,_s)) revert();
        if(balances[_to] + _value < balances[_to]
            || balances[msg.sender] + _feeSmart < balances[msg.sender]) revert();
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        balances[msg.sender] += _feeSmart;
        Transfer(_from, msg.sender, _feeSmart);
        balances[_from] -= _value + _feeSmart;
        nonces[_from] = nonce + 1;
        return true;
    }
    function approveProxy(address _from, address _spender, uint256 _value,
        uint8 _v,bytes32 _r, bytes32 _s) public returns (bool success) {
        uint256 nonce = nonces[_from];
        bytes32 hash = keccak256(_from,_spender,_value,nonce);
        if(_from != ecrecover(hash,_v,_r,_s)) revert();
        allowed[_from][_spender] = _value;
        Approval(_from, _spender, _value);
        nonces[_from] = nonce + 1;
        return true;
    }
    function getNonce(address _addr) public constant returns (uint256){
        return nonces[_addr];
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
    function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(_extraData)) { revert(); }
        return true;
    }
    function allocateTokens(address[] _owners, uint256[] _values) public {
        if(msg.sender != founder) revert();
        if(allocateEndTime < now) revert();
        if(_owners.length != _values.length) revert();
        for(uint256 i = 0; i < _owners.length ; i++){
            address owner = _owners[i];
            uint256 value = _values[i];
            if(totalSupply + value <= totalSupply || balances[owner] + value <= balances[owner]) revert();
            totalSupply += value;
            balances[owner] += value;
        }
    }
}
