contract ExrnSale {
	address public owner;
	uint256 public rate = 100 * 1e5;
	HumanStandardToken public token = HumanStandardToken(0x607122D68925c9D5DEDDdE4B284fdef81aD27AF6);
	function withdraw() public {
        require(msg.sender == owner);
		msg.sender.transfer((address(this)).balance);
	}
	function() payable public {
		require(msg.value >= 100 finney);
        uint256 exrnBuying = (msg.value * rate) / 1e18;
        uint256 exrnBought = 0;
        uint256 exrnAvailable = token.balanceOf(address(this));
        uint256 returningEth = 0;
        if (exrnAvailable == 0)
        	revert();
        bool saleFinished = false;
        if (exrnBuying >= exrnAvailable) {
        	saleFinished = true;
        	Finish();
        }
        if (exrnBuying > exrnAvailable) {
            returningEth = ((exrnBuying - exrnAvailable) * 1e18) / rate;
            exrnBuying = exrnAvailable;
        }
        exrnBought = exrnBuying;
        token.transfer(msg.sender, exrnBought);
        if (returningEth > 0)
            msg.sender.transfer(returningEth);
        Purchase(msg.sender, exrnBought, returningEth);
    }
    function ExrnSale() public {
    	owner = msg.sender;
    	Start();
    }
    event Start();
    event Purchase(address indexed _buyer, uint256 _exrnBought, uint256 _ethReturned);
    event Finish();
}
