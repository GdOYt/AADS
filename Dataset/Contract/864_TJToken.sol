contract TJToken is ERC223,SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	address public owner;
    mapping (address => uint256) public balances;
	mapping (address => uint256) public freezes;
    event Burn(address indexed from, uint256 value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
  function name() public view returns (string _name) {
      return name;
  }
  function symbol() public view returns (string _symbol) {
      return symbol;
  }
  function decimals() public view returns (uint8 _decimals) {
      return decimals;
  }
  function totalSupply() public view returns (uint256 _totalSupply) {
      return totalSupply;
  }
    function TJToken(uint256 initialSupply,string tokenName,uint8 decimalUnits,string tokenSymbol) {
        balances[msg.sender] = initialSupply * 10 ** uint256(decimalUnits);               
        totalSupply = initialSupply * 10 ** uint256(decimalUnits);                      
        name = tokenName;                                    
        symbol = tokenSymbol;                                
        decimals = decimalUnits;                             
		owner = msg.sender;
		Transfer(address(0), owner, totalSupply);
    }
    function burn(uint256 _value) returns (bool success) {
        if (balances[msg.sender] < _value) revert();             
		if (_value <= 0) revert(); 
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _value);                       
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                 
        Burn(msg.sender, _value);
        return true;
    }
	function freeze(uint256 _value) returns (bool success) {
        if (balances[msg.sender] < _value) revert();             
		if (_value <= 0) revert(); 
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _value);                       
        freezes[msg.sender] = SafeMath.safeAdd(freezes[msg.sender], _value);                                 
        Freeze(msg.sender, _value);
        return true;
    }
	function unfreeze(uint256 _value) returns (bool success) {
        if (freezes[msg.sender] < _value) revert();             
		if (_value <= 0) revert(); 
        freezes[msg.sender] = SafeMath.safeSub(freezes[msg.sender], _value);                       
		balances[msg.sender] = SafeMath.safeAdd(balances[msg.sender], _value);
        Unfreeze(msg.sender, _value);
        return true;
    }
	function withdrawTokens(address tokenContract) external {
		require(msg.sender == owner );
		WithdrawableToken tc = WithdrawableToken(tokenContract);
		tc.transfer(owner, tc.balanceOf(this));
	}
	function withdrawEther() external {
		require(msg.sender == owner );
		msg.sender.transfer(this.balance);
	}
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
    if(isContract(_to)) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  function transfer(address _to, uint _value) public returns (bool success) {
    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}
  function isContract(address _addr) private view returns (bool is_contract) {
      uint length;
      assembly {
            length := extcodesize(_addr)
      }
      return (length>0);
    }
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
	if (_data.length > 0){
		Transfer(msg.sender, _to, _value, _data);
	}
    else{
		Transfer(msg.sender, _to, _value);
	}
    return true;
  }
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    return true;
}
	function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
	function () payable {
    }
}
