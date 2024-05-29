contract MultiOwner {
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
	event RequirementChanged(uint256 newRequirement);
    uint256 public ownerRequired;
    mapping (address => bool) public isOwner;
	mapping (address => bool) public RequireDispose;
	address[] owners;
	function MultiOwner(address[] _owners, uint256 _required) public {
        ownerRequired = _required;
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
        for (uint256 i = 0; i < _owners.length; ++i){
			require(!isOwner[_owners[i]]);
			isOwner[_owners[i]] = true;
			owners.push(_owners[i]);
        }
    }
	modifier onlyOwner {
	    require(isOwner[msg.sender]);
        _;
    }
	modifier ownerDoesNotExist(address owner) {
		require(!isOwner[owner]);
        _;
    }
    modifier ownerExists(address owner) {
		require(isOwner[owner]);
        _;
    }
    function addOwner(address owner) onlyOwner ownerDoesNotExist(owner) external{
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAdded(owner);
    }
	function numberOwners() public constant returns (uint256 NumberOwners){
	    NumberOwners = owners.length;
	}
    function removeOwner(address owner) onlyOwner ownerExists(owner) external{
		require(owners.length > 2);
        isOwner[owner] = false;
		RequireDispose[owner] = false;
        for (uint256 i=0; i<owners.length - 1; i++){
            if (owners[i] == owner) {
				owners[i] = owners[owners.length - 1];
                break;
            }
		}
		owners.length -= 1;
        OwnerRemoved(owner);
    }
	function changeRequirement(uint _newRequired) onlyOwner external {
		require(_newRequired >= owners.length);
        ownerRequired = _newRequired;
        RequirementChanged(_newRequired);
    }
	function ConfirmDispose() onlyOwner() returns (bool){
		uint count = 0;
		for (uint i=0; i<owners.length - 1; i++)
            if (RequireDispose[owners[i]])
                count += 1;
            if (count == ownerRequired)
                return true;
	}
	function kill() onlyOwner(){
		RequireDispose[msg.sender] = true;
		if(ConfirmDispose()){
			selfdestruct(msg.sender);
		}
    }
}
