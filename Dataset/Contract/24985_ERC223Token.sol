contract ERC223Token is ERC223, SafeMath , Ownable{
 mapping(address => uint) balances;
 mapping(address => bool) whitelist;
 string public name;
 string public symbol;
 uint8 public decimals = 8;
 uint256 public totalSupply;
 function ERC223Token() public {
        totalSupply = 1200000000 * 10 ** uint256(decimals);   
        balances[msg.sender] = 120000000000000000;                 
        name = "Ethereum Lendo Token";                                    
        symbol = "ELT";                                
        whitelist[owner] = true;
    }
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
 function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
	 if(isContract(_to)) {
			 if (getbalance(msg.sender) < _value) revert();
			 balances[msg.sender] = safeSub(getbalance(msg.sender), _value);
			 balances[_to] = safeAdd(getbalance(_to), _value);
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
	 if(isContract(_to))
	 {
			 return transferToContract(_to, _value, empty);
	 }
	 else
	 {
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
	 if (getbalance(msg.sender) < _value) revert();
	 balances[msg.sender] = safeSub(getbalance(msg.sender), _value);
	 balances[_to] = safeAdd(getbalance(_to), _value);
	 Transfer(msg.sender, _to, _value, _data);
	 return true;
 }
 function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
	 if (getbalance(msg.sender) < _value) revert();
	 balances[msg.sender] = safeSub(getbalance(msg.sender), _value);
	 balances[_to] = safeAdd(getbalance(_to), _value);
	 ContractReceiver receiver = ContractReceiver(_to);
	 receiver.tokenFallback(msg.sender, _value, _data);
	 Transfer(msg.sender, _to, _value, _data);
	 return true;
}
 function getbalance(address _ethaddress) public view returns (uint balance) {
	 return balances[_ethaddress];
 }
 function isWhiteList(address _ethaddress) public view returns (bool iswhitelist) {
	 return whitelist[_ethaddress];
 }
}
