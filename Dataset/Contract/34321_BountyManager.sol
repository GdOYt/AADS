contract BountyManager is Ownable  {
	using SafeMath for uint256;
	Peculium public pecul;  
	bool public initPecul;  
	event InitializedToken(address contractToken);
	address public bountymanager ;  
	uint256 public bountymanagerShare;  
	bool public First_pay_bountymanager;  
	uint256 public first_pay;  
	uint256 public montly_pay;  
	bool public bountyInit;  
	uint256 public payday;  
	uint256 public nbMonthsPay;  
	event InitializedManager(address ManagerAdd);
	event FirstPaySend(uint256 first,address receiver);
	event MonthlyPaySend(uint256 monthPay,address receiverMonthly);
	function BountyManager() {
		bountymanagerShare = SafeMath.mul(72000000,(10**8));  
		first_pay = SafeMath.div(SafeMath.mul(40,bountymanagerShare),100);  
		montly_pay = SafeMath.div(SafeMath.mul(10,bountymanagerShare),100);  
		nbMonthsPay = 0;
		First_pay_bountymanager=true;
		initPecul = false;
		bountyInit==false;
	}
	function InitPeculiumAdress(address peculAdress) onlyOwner 
	{  
		pecul = Peculium(peculAdress);
		payday = pecul.dateDefrost();
		initPecul = true;
		InitializedToken(peculAdress);
	}
	function change_bounty_manager (address public_key) onlyOwner 
	{  
		bountymanager = public_key;
		bountyInit=true;
		InitializedManager(public_key);
	}
	function transferManager() onlyOwner Initialize BountyManagerInit 
	{  
		require(now > payday);
		if(First_pay_bountymanager==false && nbMonthsPay < 6)
		{
			pecul.transfer(bountymanager,montly_pay);
			payday = payday.add( 31 days);
			nbMonthsPay=nbMonthsPay.add(1);
			MonthlyPaySend(montly_pay,bountymanager);
		}
		if(First_pay_bountymanager==true)
		{
			pecul.transfer(bountymanager,first_pay);
			payday = payday.add( 35 days);
			First_pay_bountymanager=false;
			FirstPaySend(first_pay,bountymanager);
		}
	}
	modifier Initialize {  
		require (initPecul==true);
		_;
    	}
    	modifier BountyManagerInit {  
		require (bountyInit==true);
		_;
    	} 
}
