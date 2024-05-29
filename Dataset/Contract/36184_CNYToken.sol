contract CNYToken is StandardToken {
    function () {
        throw;
    }
    address public founder;                
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'CNY1.0';      
    mapping(address => uint256) nonces;
    mapping(address => string) lastComment;
    mapping (address => mapping (uint256 => string)) comments;
    function CNYToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol) {
        founder = msg.sender;                                 
        balances[msg.sender] = _initialAmount;                
        totalSupply = _initialAmount;                         
        name = _tokenName;                                    
        decimals = _decimalUnits;                             
        symbol = _tokenSymbol;                                
    }
   function transferWithComment(address _to, uint256 _value, string _comment) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            lastComment[msg.sender] = _comment;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    function transferFromWithComment(address _from, address _to, uint256 _value, string _comment) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            lastComment[_from] = _comment;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferProxy(address _from, address _to, uint256 _value, uint256 _fee,
        uint8 _v,bytes32 _r, bytes32 _s, string _comment) returns (bool){
        if(balances[_from] < _fee + _value) throw;
        uint256 nonce = nonces[_from];
        bytes32 hash = sha3(_from,_to,_value,_fee,nonce);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = sha3(prefix, hash);
        if(_from != ecrecover(prefixedHash,_v,_r,_s)) throw;
        if(balances[_to] + _value < balances[_to]
            || balances[msg.sender] + _fee < balances[msg.sender]) throw;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        balances[msg.sender] += _fee;
        Transfer(_from, msg.sender, _fee);
        balances[_from] -= _value + _fee;
        lastComment[_from] = _comment;
        comments[_from][nonce] = _comment;
        nonces[_from] = nonce + 1;
        return true;
    }
    function approveProxy(address _from, address _spender, uint256 _value,
        uint8 _v,bytes32 _r, bytes32 _s, string _comment) returns (bool success) {
        if(balances[_from] < _value) throw;
        uint256 nonce = nonces[_from];
        bytes32 hash = sha3(_from,_spender,_value,nonce);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = sha3(prefix, hash);
        if(_from != ecrecover(prefixedHash,_v,_r,_s)) throw;
        allowed[_from][_spender] = _value;
        Approval(_from, _spender, _value);
        lastComment[_from] = _comment;
        comments[_from][nonce] = _comment;
        nonces[_from] = nonce + 1;
        return true;
    }
    function getNonce(address _addr) constant returns (uint256){
        return nonces[_addr];
    }
    function getLastComment(address _addr) constant returns (string){
        return lastComment[_addr];
    }
    function getSpecifiedComment(address _addr, uint256 _nonce) constant returns (string){
        if (nonces[_addr] < _nonce) throw;
        return comments[_addr][_nonce];
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
    function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(_extraData)) { throw; }
        return true;
    }
    event Burn(address indexed from, uint256 value);
    function burn(uint256 _value) returns (bool success) {
        if (balances[msg.sender] < _value) throw;             
        balances[msg.sender] -= _value;                       
        totalSupply -= _value;                                 
        Burn(msg.sender, _value);
        return true;
    }
    function burnFrom(address _from, uint256 _value) returns (bool success) {
        if (balances[_from] < _value) throw;                 
        if (_value > allowed[_from][msg.sender]) throw;     
        balances[_from] -= _value;                           
        totalSupply -= _value;                                
        Burn(_from, _value);
        return true;
    }
    event Increase(address _to, uint256 _value);
    function allocateTokens(address _to, uint256 _value) {
        if(msg.sender != founder) throw;             
        if(totalSupply + _value <= totalSupply || balances[_to] + _value <= balances[_to]) throw;
        totalSupply += _value;
        balances[_to] += _value;
        Increase(_to,_value);
    }
}
