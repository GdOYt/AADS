contract MinterStorePoolCrowdsale is Ownable {
using SafeMath for uint;
address public multisigWallet;
uint public startRound;
uint public periodRound;
uint public altCapitalization;
uint public totalCapitalization;
MinterStorePool public token = new MinterStorePool ();
function MinterStorePoolCrowdsale () public {
	multisigWallet = 0xdee04DfdC6C93D51468ba5cd90457Ac0B88055FD;
	startRound = 1534118340;
	periodRound = 80;
	altCapitalization = 0;
	totalCapitalization = 2000 ether;
	}
modifier CrowdsaleIsOn() {
	require(now >= startRound && now <= startRound + periodRound * 1 days);
	_;
	}
modifier TotalCapitalization() {
	require(multisigWallet.balance + altCapitalization <= totalCapitalization);
	_;
	}
function setMultisigWallet (address newMultisigWallet) public onlyOwner {
	require(newMultisigWallet != 0X0);
	multisigWallet = newMultisigWallet;
	}
function setStartRound (uint newStartRound) public onlyOwner {
	startRound = newStartRound;
	}
function setPeriodRound (uint newPeriodRound) public onlyOwner {
	periodRound = newPeriodRound;
	} 
function setAltCapitalization (uint newAltCapitalization) public onlyOwner {
	altCapitalization = newAltCapitalization;
	}
function setTotalCapitalization (uint newTotalCapitalization) public onlyOwner {
	totalCapitalization = newTotalCapitalization;
	}
function () external payable {
	createTokens (msg.sender, msg.value);
	}
function createTokens (address recipient, uint etherDonat) internal CrowdsaleIsOn TotalCapitalization {
	require(etherDonat > 0);  
	require(recipient != 0X0);
	multisigWallet.transfer(etherDonat);
    uint tokens = 10000000000000;  
	token.mint(recipient, tokens);
	}
function customCreateTokens(address recipient, uint btcDonat) public CrowdsaleIsOn TotalCapitalization onlyOwner {
	require(btcDonat > 0);  
	require(recipient != 0X0);
    uint tokens = btcDonat;
	token.mint(recipient, tokens);
	}
function retrieveTokens (address addressToken, address wallet) public onlyOwner {
	ERC20 alientToken = ERC20 (addressToken);
	alientToken.transfer(wallet, alientToken.balanceOf(this));
	}
function finishMinting () public onlyOwner {
	token.finishMinting();
	}
function setOwnerToken (address newOwnerToken) public onlyOwner {
	require(newOwnerToken != 0X0);
	token.transferOwnership(newOwnerToken); 
	}
}
