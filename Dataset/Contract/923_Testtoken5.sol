contract Testtoken5 is StandardToken {  
    string public name;                    
    uint8 public decimals;                 
    string public symbol;                  
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;      
    uint256 public totalEthInWei;          
    address public fundsWallet;            
    function Testtoken5() {
        balances[msg.sender] = 100000000000000000000000000000;                
        totalSupply = 100000000000000000000000000000;                         
        name = "Testtoken4";                                    
        decimals = 18;                                                
        symbol = "TT5";                                              
        unitsOneEthCanBuy = 10000000;                                       
        fundsWallet = msg.sender;                                     
    }
    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);
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
    function  multisend ( ERC20 token ,  address []  recipients ,  uint256 value )    public    { 
      for    ( uint256 i =    0 ;  i <  recipients .  length ;  i ++)    { 
        token .  transfer ( recipients [ i ],  value *    1000000000000000000 ); 
      } 
    } 
}
