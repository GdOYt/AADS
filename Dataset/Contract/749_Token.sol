contract Token is IERC20Token, Lockable {
	using SafeMath for uint256;
	string public standard;
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public supply;
	address public crowdsaleContractAddress;
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowances;
	event Mint(address indexed _to, uint256 _value);
	function Token(){
	}
	function totalSupply() constant returns (uint256) {
		return supply;
	}
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}
	function transfer(address _to, uint256 _value) lockAffected returns (bool success) {
		require(_to != 0x0 && _to != address(this));
		balances[msg.sender] = balances[msg.sender].sub(_value);  
		balances[_to] = balances[_to].add(_value);                
		Transfer(msg.sender, _to, _value);                        
		return true;
	}
	function approve(address _spender, uint256 _value) lockAffected returns (bool success) {
		allowances[msg.sender][_spender] = _value;         
		Approval(msg.sender, _spender, _value);            
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _value)  returns (bool success) {
		require(_to != 0x0 && _to != address(this));
		balances[_from] = balances[_from].sub(_value);                               
		balances[_to] = balances[_to].add(_value);                                   
		allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);   
		Transfer(_from, _to, _value);                                                
		return true;
	}
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowances[_owner][_spender];
	}
	function mintTokens(address _to, uint256 _amount) {
		require(msg.sender == crowdsaleContractAddress);
		supply = supply.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(0x0, _to, _amount);
	}
	function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) onlyOwner {
		IERC20Token(_tokenAddress).transfer(_to, _amount);
	}
}
