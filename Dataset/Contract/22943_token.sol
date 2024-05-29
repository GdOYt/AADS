contract token {
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Burn(address indexed from, uint256 value);
	function token(uint256 initialSupply, string tokenName,	uint8 decimalCount, string tokenSymbol) public {
	    decimals = decimalCount;
		totalSupply = initialSupply * 10 ** uint256(decimals);  
		balanceOf[msg.sender] = totalSupply;  
		name = tokenName;  
		symbol = tokenSymbol;  
	}
	function transfer(address _to, uint256 _value) {
		if (balanceOf[msg.sender] < _value) throw;  
		if (balanceOf[_to] + _value < balanceOf[_to]) throw;  
		balanceOf[msg.sender] -= _value;  
		balanceOf[_to] += _value;  
		Transfer(msg.sender, _to, _value);  
	}
	function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
		if (balanceOf[_from] < _value) throw;  
		if (balanceOf[_to] + _value < balanceOf[_to]) throw;  
		if (_value > allowance[_from][msg.sender]) throw;  
		balanceOf[_from] -= _value;  
		balanceOf[_to] += _value;  
		allowance[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);
		return true;
	}
	function approve(address _spender, uint256 _value) public
	returns(bool success) {
		allowance[msg.sender][_spender] = _value;
		return true;
	}
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}
	function burn(uint256 _value) public returns(bool success) {
		require(balanceOf[msg.sender] >= _value);  
		balanceOf[msg.sender] -= _value;  
		totalSupply -= _value;  
		Burn(msg.sender, _value);
		return true;
	}
	function burnFrom(address _from, uint256 _value) public returns(bool success) {
		require(balanceOf[_from] >= _value);  
		require(_value <= allowance[_from][msg.sender]);  
		balanceOf[_from] -= _value;  
		allowance[_from][msg.sender] -= _value;  
		totalSupply -= _value;  
		Burn(_from, _value);
		return true;
	}
}