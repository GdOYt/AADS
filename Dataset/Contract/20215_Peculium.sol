contract Peculium is BurnableToken,Ownable {  
	PeculiumOld public peculOld;  
	address public peculOldAdress = 0x53148Bb4551707edF51a1e8d7A93698d18931225;  
	using SafeMath for uint256;  
	using SafeERC20 for ERC20Basic; 
	string public name = "Peculium";  
    	string public symbol = "PCL";  
    	uint256 public decimals = 8;  
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8;  
	mapping(address => bool) public balancesCannotSell;  
	event ChangedTokens(address changedTarget,uint256 amountToChanged);
	event FrozenFunds(address address_target, bool bool_canSell);
	function Peculium() public {
		totalSupply = MAX_SUPPLY_NBTOKEN;
		balances[address(this)] = totalSupply;  
		peculOld = PeculiumOld(peculOldAdress);	
	}
	function transfer(address _to, uint256 _value) public returns (bool) 
	{  
		require(balancesCannotSell[msg.sender]==false);
		return BasicToken.transfer(_to,_value);
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{  
		require(balancesCannotSell[msg.sender]==false);	
		return StandardToken.transferFrom(_from,_to,_value);
	}
   	function ChangeLicense(address target, bool canSell) public onlyOwner
   	{
        	balancesCannotSell[target] = canSell;
        	FrozenFunds(target, canSell);
    	}
    		function UpgradeTokens() public
	{
		require(peculOld.totalSupply()>0);
		uint256 amountChanged = peculOld.allowance(msg.sender,address(this));
		require(amountChanged>0);
		peculOld.transferFrom(msg.sender,address(this),amountChanged);
		peculOld.burn(amountChanged);
		balances[address(this)] = balances[address(this)].sub(amountChanged);
    		balances[msg.sender] = balances[msg.sender].add(amountChanged);
		Transfer(address(this), msg.sender, amountChanged);
		ChangedTokens(msg.sender,amountChanged);
	}
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }
  	function getBlockTimestamp() public constant returns (uint256)
  	{
        	return now;
  	}
  	function getOwnerInfos() public constant returns (address ownerAddr, uint256 ownerBalance)  
  	{  
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	}
}
