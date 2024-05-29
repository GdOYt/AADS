contract RefundVault is HardcodedWallets, System {
	using SafeMath for uint256;
	enum State { Active, Refunding, Closed }
	mapping (address => uint256) public deposited;
	mapping (address => uint256) public tokensAcquired;
	State public state;
	address public addressSCICO;
	modifier onlyICOContract() {
		if (msg.sender != addressSCICO) {
			error('RefundVault: onlyICOContract function called by user that is not ICOContract');
		} else {
			_;
		}
	}
	constructor() public {
		state = State.Active;
	}
	function weisDeposited(address _investor) public constant returns (uint256) {
		return deposited[_investor];
	}
	function getTokensAcquired(address _investor) public constant returns (uint256) {
		return tokensAcquired[_investor];
	}
	function deposit(address _investor, uint256 _tokenAmount) onlyICOContract public payable returns (bool) {
		if (state != State.Active) {
			error('deposit: state != State.Active');
			return false;
		}
		deposited[_investor] = deposited[_investor].add(msg.value);
		tokensAcquired[_investor] = tokensAcquired[_investor].add(_tokenAmount);
		return true;
	}
	function close() onlyICOContract public returns (bool) {
		if (state != State.Active) {
			error('close: state != State.Active');
			return false;
		}
		state = State.Closed;
		walletFounder1.transfer(address(this).balance.mul(33).div(100));  
		walletFounder2.transfer(address(this).balance.mul(50).div(100));  
		walletFounder3.transfer(address(this).balance);                   
		emit Closed();  
		return true;
	}
	function enableRefunds() onlyICOContract public returns (bool) {
		if (state != State.Active) {
			error('enableRefunds: state != State.Active');
			return false;
		}
		state = State.Refunding;
		emit RefundsEnabled();  
		return true;
	}
	function refund(address _investor) onlyICOContract public returns (bool) {
		if (state != State.Refunding) {
			error('refund: state != State.Refunding');
			return false;
		}
		if (deposited[_investor] == 0) {
			error('refund: no deposit to refund');
			return false;
		}
		uint256 depositedValue = deposited[_investor];
		deposited[_investor] = 0;
		tokensAcquired[_investor] = 0;  
		_investor.transfer(depositedValue);
		emit Refunded(_investor, depositedValue);  
		return true;
	}
	function isRefunding() public constant returns (bool) {
		return (state == State.Refunding);
	}
	function setMyICOContract(address _SCICO) public onlyOwner {
		require(address(this).balance == 0);
		addressSCICO = _SCICO;
	}
	event Closed();
	event RefundsEnabled();
	event Refunded(address indexed beneficiary, uint256 weiAmount);
}
