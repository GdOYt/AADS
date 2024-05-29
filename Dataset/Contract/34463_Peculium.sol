contract Peculium is BurnableToken,Ownable {  
	using SafeMath for uint256;  
	using SafeERC20 for ERC20Basic; 
	string public name = "Peculium";  
    	string public symbol = "PCL";  
    	uint256 public decimals = 8;  
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8;  
	uint256 public dateStartContract;  
	mapping(address => bool) public balancesCanSell;  
	uint256 public dateDefrost;  
 	event FrozenFunds(address target, bool frozen);     	 
     	event Defroze(address msgAdd, bool freeze);
	function Peculium() {
		totalSupply = MAX_SUPPLY_NBTOKEN;
		balances[owner] = totalSupply;  
		balancesCanSell[owner] = true;  
		dateStartContract=now;
		dateDefrost = dateStartContract + 85 days;  
	}
	function defrostToken() public 
	{  
		require(now>dateDefrost);
		balancesCanSell[msg.sender]=true;
		Defroze(msg.sender,true);
	}
	function transfer(address _to, uint256 _value) public returns (bool) 
	{  
		require(balancesCanSell[msg.sender]);
		return BasicToken.transfer(_to,_value);
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{  
		require(balancesCanSell[msg.sender]);	
		return StandardToken.transferFrom(_from,_to,_value);
	}
   	function freezeAccount(address target, bool canSell) onlyOwner 
   	{
        	balancesCanSell[target] = canSell;
        	FrozenFunds(target, canSell);
    	}
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }
  	function getBlockTimestamp() constant returns (uint256)
  	{
        	return now;
  	}
  	function getOwnerInfos() constant returns (address ownerAddr, uint256 ownerBalance)  
  	{  
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	}
}
