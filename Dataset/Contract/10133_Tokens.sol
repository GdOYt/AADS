contract Tokens is HardcodedWallets, ERC20, Haltable {
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 public _totalSupply; 
	string public name;
	string public symbol;
	uint8 public decimals;
	string public standard = 'H0.1';  
	uint256 public timelockEndTime;
	address public addressSCICO;
	address public addressSCEscrow;
	address public addressSCComplianceService;
	ComplianceService public SCComplianceService;
	modifier notTimeLocked() {
		if (now < timelockEndTime && msg.sender != addressSCICO && msg.sender != addressSCEscrow) {
			error('notTimeLocked: Timelock still active. Function is yet unavailable.');
		} else {
			_;
		}
	}
	constructor(address _addressSCEscrow, address _addressSCComplianceService) public {
		name = "TheRentalsToken";
		symbol = "TRT";
		decimals = 18;  
        _totalSupply = 1350000000 ether;  
		timelockEndTime = timestamp().add(45 days);  
		addressSCEscrow = _addressSCEscrow;
		addressSCComplianceService = _addressSCComplianceService;
		SCComplianceService = ComplianceService(addressSCComplianceService);
		balances[_addressSCEscrow] = _totalSupply;
		emit Transfer(0x0, _addressSCEscrow, _totalSupply);
	}
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return balances[_owner];
	}
	function transfer(address _to, uint256 _amount) public notTimeLocked stopInEmergency returns (bool success) {
		if (balances[msg.sender] < _amount) {
			error('transfer: the amount to transfer is higher than your token balance');
			return false;
		}
		if(!SCComplianceService.validate(msg.sender, _to, _amount)) {
			error('transfer: not allowed by the compliance service');
			return false;
		}
		balances[msg.sender] = balances[msg.sender].sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Transfer(msg.sender, _to, _amount);  
		return true;
	}
	function transferFrom(address _from, address _to, uint256 _amount) public notTimeLocked stopInEmergency returns (bool success) {
		if (balances[_from] < _amount) {
			error('transferFrom: the amount to transfer is higher than the token balance of the source');
			return false;
		}
		if (allowed[_from][msg.sender] < _amount) {
			error('transferFrom: the amount to transfer is higher than the maximum token transfer allowed by the source');
			return false;
		}
		if(!SCComplianceService.validate(_from, _to, _amount)) {
			error('transfer: not allowed by the compliance service');
			return false;
		}
		balances[_from] = balances[_from].sub(_amount);
		balances[_to] = balances[_to].add(_amount);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
		emit Transfer(_from, _to, _amount);  
		return true;
	}
	function approve(address _spender, uint256 _amount) public returns (bool success) {
		allowed[msg.sender][_spender] = _amount;
		emit Approval(msg.sender, _spender, _amount);  
		return true;
	}
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
	function refundTokens(address _from, uint256 _amount) public notTimeLocked stopInEmergency returns (bool success) {
        if (tx.origin != _from) {
            error('refundTokens: tx.origin did not request the refund directly');
            return false;
        }
        if (addressSCICO != msg.sender) {
            error('refundTokens: caller is not the current ICO address');
            return false;
        }
        if (balances[_from] < _amount) {
            error('refundTokens: the amount to transfer is higher than your token balance');
            return false;
        }
        if(!SCComplianceService.validate(_from, addressSCICO, _amount)) {
			error('transfer: not allowed by the compliance service');
			return false;
		}
		balances[_from] = balances[_from].sub(_amount);
		balances[addressSCICO] = balances[addressSCICO].add(_amount);
		emit Transfer(_from, addressSCICO, _amount);  
		return true;
	}
	function setMyICOContract(address _SCICO) public onlyOwner {
		addressSCICO = _SCICO;
	}
	function setComplianceService(address _addressSCComplianceService) public onlyOwner {
		addressSCComplianceService = _addressSCComplianceService;
		SCComplianceService = ComplianceService(addressSCComplianceService);
	}
	function updateTimeLock(uint256 _timelockEndTime) onlyOwner public returns (bool) {
		timelockEndTime = _timelockEndTime;
		emit UpdateTimeLock(_timelockEndTime);  
		return true;
	}
	event Transfer(address indexed _from, address indexed _to, uint256 _amount);
	event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
	event UpdateTimeLock(uint256 _timelockEndTime);
}
