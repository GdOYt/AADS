contract LOFO is StandardToken {  
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'L1.0'; 
    uint256 public unitsOneEthCanBuy;     
    uint256 public totalEthInWei;           
    address public fundsWallet;           
    function LOFO() {
        balances[msg.sender] = 10000000000000000000000000000;               
        totalSupply = 10000000000000000000000000000;                        
        name = "LOFO";                                   
        decimals = 18;                                               
        symbol = "LOFO";                                             
        unitsOneEthCanBuy = 125000;                                      
        fundsWallet = msg.sender;                                
    }
    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        if (balances[fundsWallet] < amount) {
            return;
        }
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        Transfer(fundsWallet, msg.sender, amount);  
        fundsWallet.transfer(msg.value);                               
    }
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}