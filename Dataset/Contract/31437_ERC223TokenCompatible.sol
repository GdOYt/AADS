contract ERC223TokenCompatible is BasicToken {
  using SafeMath for uint256;
  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
	function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public returns (bool success) {
		require(_to != address(0));
        require(_to != address(this));
		require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
		if( isContract(_to) ) {
			_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data);
		} 
		Transfer(msg.sender, _to, _value, _data);
		return true;
	}
	function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {
		return transfer( _to, _value, _data, "tokenFallback(address,uint256,bytes)");
	}
	function isContract(address _addr) private view returns (bool is_contract) {
		uint256 length;
		assembly {
            length := extcodesize(_addr)
		}
		return (length>0);
    }
}
