contract Timelock is Ownable {
	tokenInterface public tokenContract;
	uint256 public releaseTime;
	constructor(address _tokenAddress, uint256 _releaseTime) public {
		tokenContract = tokenInterface(_tokenAddress);
		releaseTime = _releaseTime;
	}
	function () public {
	    if ( msg.sender == newOwner ) acceptOwnership();
		claim();
	}
	function claim() onlyOwner private {
	    require ( now > releaseTime, "now > releaseTime" );
	    uint256 tknToSend = tokenContract.balanceOf(this);
		require(tknToSend > 0,"tknToSend > 0");
		require ( tokenContract.transfer(msg.sender, tknToSend) );
	}
	function unlocked() view public returns(bool) {
	    return now > releaseTime;
	}
}
