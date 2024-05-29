contract POPcoin is StandardToken {
function () {
throw;
}
string public name = 'POPcoin'; 
uint8 public decimals = 3; 
string public symbol = 'POPN'; 
string public version = 'H1.0';  
function POPcoin(
) {
balances[msg.sender] = 777000000000000000000000;  
totalSupply = 777000000000000000000000;  
name = 'POPcoin';  
decimals = 18;  
symbol = 'POPN';  
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
return true;
}
}
