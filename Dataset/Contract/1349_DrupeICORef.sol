contract DrupeICORef {
	address _referrer;
	DrupeICO _ico;
	constructor(address referrer, DrupeICO ico) public {
		_referrer = referrer;
		_ico = ico;
	}
	function() public payable {
		_ico.purchase.value(msg.value)(msg.sender, _referrer);
	}
}
