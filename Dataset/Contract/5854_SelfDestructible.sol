contract SelfDestructible is Owned {
	uint public initiationTime;
	bool public selfDestructInitiated;
	address public selfDestructBeneficiary;
	uint public constant SELFDESTRUCT_DELAY = 4 weeks;
	constructor(address _owner)
	    Owned(_owner)
	    public
	{
		require(_owner != address(0));
		selfDestructBeneficiary = _owner;
		emit SelfDestructBeneficiaryUpdated(_owner);
	}
	function setSelfDestructBeneficiary(address _beneficiary)
		external
		onlyOwner
	{
		require(_beneficiary != address(0));
		selfDestructBeneficiary = _beneficiary;
		emit SelfDestructBeneficiaryUpdated(_beneficiary);
	}
	function initiateSelfDestruct()
		external
		onlyOwner
	{
		initiationTime = now;
		selfDestructInitiated = true;
		emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
	}
	function terminateSelfDestruct()
		external
		onlyOwner
	{
		initiationTime = 0;
		selfDestructInitiated = false;
		emit SelfDestructTerminated();
	}
	function selfDestruct()
		external
		onlyOwner
	{
		require(selfDestructInitiated && initiationTime + SELFDESTRUCT_DELAY < now);
		address beneficiary = selfDestructBeneficiary;
		emit SelfDestructed(beneficiary);
		selfdestruct(beneficiary);
	}
	event SelfDestructTerminated();
	event SelfDestructed(address beneficiary);
	event SelfDestructInitiated(uint selfDestructDelay);
	event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}
