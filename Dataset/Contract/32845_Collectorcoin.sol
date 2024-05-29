contract Collectorcoin is StandardToken {
    function () {
        throw;}
    string public name = 'Collectorcoin';                   
    uint8 public decimals = 2;                
    string public symbol = 'CLC';                 
    string public version = 'H1.0';       
    function Collectorcoin(
        ) {
        balances[msg.sender] = 100000000000;               
        totalSupply = 100000000000;                        
        name = "Collectorcoin";                                   
        decimals = 2;                            
        symbol = "CLC";}
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;}}
