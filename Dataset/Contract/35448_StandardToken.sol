contract StandardToken is owned{
    using ERC20Lib for ERC20Lib.TokenStorage;
    ERC20Lib.TokenStorage public token;
	string public name;                    
    uint8 public decimals=18;                 
    string public symbol;                  
    string public version = 'H0.1';        
    uint public INITIAL_SUPPLY = 0;		 
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);   
    function StandardToken() {
		token.init(INITIAL_SUPPLY);
    }
    function totalSupply() constant returns (uint) {
		return token.totalSupply;
    }
    function balanceOf(address who) constant returns (uint) {
		return token.balanceOf(who);
    }
    function allowance(address owner, address _spender) constant returns (uint) {
		return token.allowance(owner, _spender);
    }
	function transfer(address to, uint value) returns (bool ok) {
		return token.transfer(to, value);
	}
	function transferFrom(address _from, address _to, uint _value) returns (bool ok) {
		return token.transferFrom(_from, _to, _value);
	}
	function approve(address _spender, uint value) returns (bool ok) {
		return token.approve(_spender, value);
	}
	function increaseApproval(address _spender, uint256 _addedValue) returns (bool ok) {  
		return token.increaseApproval(_spender, _addedValue);
	}    
	function decreaseApproval(address _spender, uint256 _subtractedValue) returns (bool ok) {  
		return token.decreaseApproval(_spender, _subtractedValue);
	}
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool ok){
		return token.approveAndCall(_spender,_value,_extraData);
    }
	function mintCoin(address target, uint256 mintedAmount) onlyOwner returns (bool ok) {
		return token.mintCoin(target,mintedAmount,owner);
    }
    function meltCoin(address target, uint256 meltedAmount) onlyOwner returns (bool ok) {
		return token.meltCoin(target,meltedAmount,owner);
    }
}
