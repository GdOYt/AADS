contract NXX is ERC223, Pausable {
	using SafeMath for uint256;
	using ContractLib for address;
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
	event Burn(address indexed from, uint256 value);
	function NXX() public {
		symbol = "NASHXX";
		name = "XXXX CASH";
		decimals = 18;
		totalSupply = 100000000000 * 10**uint(decimals);
		balances[msg.sender] = totalSupply;
		emit Transfer(address(0), msg.sender, totalSupply);
	}
	function name() public constant returns (string) {
		return name;
	}
	function symbol() public constant returns (string) {
		return symbol;
	}
	function decimals() public constant returns (uint8) {
		return decimals;
	}
	function totalSupply() public constant returns (uint256) {
		return totalSupply;
	}
	function transfer(address _to, uint _value, bytes _data) public whenNotPaused returns (bool) {
		require(_to != 0x0);
		if(_to.isContract()) {
			return transferToContract(_to, _value, _data);
		}
		else {
			return transferToAddress(_to, _value, _data);
		}
	}
	function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
		require(_to != 0x0);
		bytes memory empty;
		if(_to.isContract()) {
			return transferToContract(_to, _value, empty);
		}
		else {
			return transferToAddress(_to, _value, empty);
		}
	}
	function transferToAddress(address _to, uint _value, bytes _data) private returns (bool) {
		balances[msg.sender] = balanceOf(msg.sender).sub(_value);
		balances[_to] = balanceOf(_to).add(_value);
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
	    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
	    balances[_to] = balanceOf(_to).add(_value);
	    ContractReceiver receiver = ContractReceiver(_to);
	    receiver.tokenFallback(msg.sender, _value, _data);
	    emit Transfer(msg.sender, _to, _value);
	    emit Transfer(msg.sender, _to, _value, _data);
	    return true;
	}
	function balanceOf(address _owner) public constant returns (uint) {
		return balances[_owner];
	}  
	function burn(uint256 _value) public whenNotPaused returns (bool) {
		require (_value > 0); 
		require (balanceOf(msg.sender) >= _value);             
		balances[msg.sender] = balanceOf(msg.sender).sub(_value);                       
		totalSupply = totalSupply.sub(_value);                                 
		emit Burn(msg.sender, _value);
		return true;
	}
	function approve(address spender, uint tokens) public whenNotPaused returns (bool) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}
	function increaseApproval (address _spender, uint _addedValue) public whenNotPaused
	    returns (bool success) {
	    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
	    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	    return true;
	}
	function decreaseApproval (address _spender, uint _subtractedValue) public whenNotPaused
	    returns (bool success) {
	    uint oldValue = allowed[msg.sender][_spender];
	    if (_subtractedValue > oldValue) {
	      allowed[msg.sender][_spender] = 0;
	    } else {
	      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
	    }
	    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
	    return true;
	}	
	function transferFrom(address from, address to, uint tokens) public whenNotPaused returns (bool) {
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		balances[from] = balances[from].sub(tokens);
		balances[to] = balances[to].add(tokens);
		emit Transfer(from, to, tokens);
		return true;
	}
	function allowance(address tokenOwner, address spender) public constant returns (uint) {
		return allowed[tokenOwner][spender];
	}
	function () public payable {
		revert();
	}
	function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool) {
		return ERC20Interface(tokenAddress).transfer(owner, tokens);
	}
	address[] supportedERC20Token;
	mapping (address => uint256) prices;
	mapping (address => uint256) starttime;
	mapping (address => uint256) endtime;
	uint256 maxTokenCountPerTrans = 10000;
	uint256 nashInPool;
	event AddSupportedToken(
		address _address, 
		uint256 _price, 
		uint256 _startTime, 
		uint256 _endTime);
	event RemoveSupportedToken(
		address _address
	);
	function addSupportedToken(
		address _address, 
		uint256 _price, 
		uint256 _startTime, 
		uint256 _endTime
	) public onlyOwner returns (bool) {
		require(_address != 0x0);
		require(_address.isContract());
		require(_startTime < _endTime);
		require(_endTime > block.timestamp);
		supportedERC20Token.push(_address);
		prices[_address] = _price;
		starttime[_address] = _startTime;
		endtime[_address] = _endTime;
		emit AddSupportedToken(_address, _price, _startTime, _endTime);
		return true;
	}
	function removeSupportedToken(address _address) public onlyOwner returns (bool) {
		require(_address != 0x0);
		uint256 length = supportedERC20Token.length;
		for (uint256 i = 0; i < length; i++) {
			if (supportedERC20Token[i] == _address) {
				if (i != length - 1) {
					supportedERC20Token[i] = supportedERC20Token[length - 1];
				}
                delete supportedERC20Token[length-1];
				supportedERC20Token.length--;
				prices[_address] = 0;
				starttime[_address] = 0;
				endtime[_address] = 0;
				emit RemoveSupportedToken(_address);
				break;
			}
		}
		return true;
	}
	modifier canBuy(address _address) { 
		bool found = false;
		uint256 length = supportedERC20Token.length;
		for (uint256 i = 0; i < length; i++) {
			if (supportedERC20Token[i] == _address) {
				require(block.timestamp > starttime[_address]);
				require(block.timestamp < endtime[_address]);
				found = true;
				break;
			}
		}		
		require (found); 
		_; 
	}
	function joinPreSale(address _tokenAddress, uint256 _tokenCount) public canBuy(_tokenAddress) returns (bool) {
		require(_tokenCount <= maxTokenCountPerTrans); 
		uint256 total = _tokenCount * prices[_tokenAddress];  
		balances[msg.sender].sub(total);
		nashInPool.add(total);
		emit Transfer(_tokenAddress, this, total);
		return ERC20Interface(_tokenCount).transfer(msg.sender, _tokenCount);
	}
	function transferNashOut(address _to, uint256 count) public onlyOwner returns(bool) {
		require(_to != 0x0);
		nashInPool.sub(count);
		balances[_to].add(count);
		emit Transfer(this, _to, count);
	}
}
