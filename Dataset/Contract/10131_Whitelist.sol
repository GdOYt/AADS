contract Whitelist is HardcodedWallets, System {
	mapping (address => bool) public walletsICO;
	mapping (address => bool) public managers;
	function isInvestor(address _wallet) public constant returns (bool) {
		return (walletsICO[_wallet]);
	}
	function addInvestor(address _wallet) external isManager returns (bool) {
		if (walletsICO[_wallet]) {
			error('addInvestor: this wallet has been previously granted as ICO investor');
			return false;
		}
		walletsICO[_wallet] = true;
		emit AddInvestor(_wallet, timestamp());  
		return true;
	}
	modifier isManager(){
		if (managers[msg.sender] || msg.sender == owner) {
			_;
		} else {
			error("isManager: called by user that is not owner or manager");
		}
	}
	function addManager(address _managerAddr) external onlyOwner returns (bool) {
		if(managers[_managerAddr]){
			error("addManager: manager account already exists.");
			return false;
		}
		managers[_managerAddr] = true;
		emit AddManager(_managerAddr, timestamp());
	}
	function delManager(address _managerAddr) external onlyOwner returns (bool) {
		if(!managers[_managerAddr]){
			error("delManager: manager account not found.");
			return false;
		}
		delete managers[_managerAddr];
		emit DelManager(_managerAddr, timestamp());
	}
	event AddInvestor(address indexed _wallet, uint256 _timestamp);
	event AddManager(address indexed _managerAddr, uint256 _timestamp);
	event DelManager(address indexed _managerAddr, uint256 _timestamp);
}
