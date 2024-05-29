contract Crowdsale is CrowdsaleLimit, Haltable {
  using SafeMath for uint256;
  CrowdsaleTokenInterface public token;
  address public multisigWallet;
  mapping (address => uint256) public investedAmountOf;
  mapping (address => uint256) public tokenAmountOf;
  uint public tokensSold = 0;
  uint public investorCount = 0;
  uint public loadedRefund = 0;
  bool public finalized;
  enum State{Unknown, PreFunding, Funding, Success, Failure, Finalized, Refunding}
  event Invested(address investor, uint weiAmount, uint tokenAmount);
  event createTeamTokenEvent(address addr, uint tokens);
  event Finalized();
  modifier inState(State state) {
    if(getState() != state) revert();
    _;
  }
  function Crowdsale(address _token, address _multisigWallet, uint _start, uint _end) CrowdsaleLimit(_start, _end) public
  {
    require(_token != 0x0);
    require(_multisigWallet != 0x0);
	token = CrowdsaleTokenInterface(_token);	
	if(token_decimals != token.decimals()) revert();
	multisigWallet = _multisigWallet;
  }
  function getState() public constant returns (State) {
    if(finalized) return State.Finalized;
    else if (now < startsAt) return State.PreFunding;
    else if (now <= endsAt && !isMinimumGoalReached()) return State.Funding;
    else if (isMinimumGoalReached()) return State.Success;
    else if (!isMinimumGoalReached() && crowdsale_eth_fund > 0 && loadedRefund >= crowdsale_eth_fund) return State.Refunding;
    else return State.Failure;
  }
  function addTeamAddress(address addr, uint release_time, uint token_percentage) onlyOwner inState(State.PreFunding) public {
	super.addTeamAddressInternal(addr, release_time, token_percentage);
	token.addLockAddress(addr, release_time);   
  }
  function createTeamTokenByPercentage() onlyOwner internal {
	uint total= tokensSold;
	uint tokens= total.mul(team_token_percentage_total).div(100-team_token_percentage_total);
	for(uint i=0; i<team_address_count; i++) {
		address addr= team_addresses_idx[i];
		if(addr==0x0) continue;
		uint ntoken= tokens.mul(team_addresses_token_percentage[addr]).div(team_token_percentage_total);
		token.mint(addr, ntoken);		
		createTeamTokenEvent(addr, ntoken);
	}
  }
  function () stopInEmergency allowCrowdsaleAmountLimit payable public {
	require(msg.sender != 0x0);
    buyTokensCrowdsale(msg.sender);
  }
  function buyTokensCrowdsale(address receiver) internal   {
	uint256 weiAmount = msg.value;
	uint256 tokenAmount= 0;
	if(getState() == State.PreFunding) {
		if (weiAmount < PRESALE_ETH_IN_WEI_ACCEPTED_MIN) revert();
		if((PRESALE_ETH_IN_WEI_FUND_MAX > 0) && ((presale_eth_fund.add(weiAmount)) > PRESALE_ETH_IN_WEI_FUND_MAX)) revert();		
		tokenAmount = calculateTokenPresale(weiAmount, token_decimals);
		presale_eth_fund = presale_eth_fund.add(weiAmount);
	}
	else if((getState() == State.Funding) || (getState() == State.Success)) {
		if (weiAmount < CROWDSALE_ETH_IN_WEI_ACCEPTED_MIN) revert();
		tokenAmount = calculateTokenCrowsale(weiAmount, token_decimals);
    } else {
      revert();
    }
	if(tokenAmount == 0) {
		revert();
	}	
	if(investedAmountOf[receiver] == 0) {
       investorCount++;
    }
    investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].add(tokenAmount);
	crowdsale_eth_fund = crowdsale_eth_fund.add(weiAmount);
	tokensSold = tokensSold.add(tokenAmount);
    token.mint(receiver, tokenAmount);
    if(!multisigWallet.send(weiAmount)) revert();
    Invested(receiver, weiAmount, tokenAmount);
  }
  function loadRefund() public payable inState(State.Failure) {
    if(msg.value == 0) revert();
    loadedRefund = loadedRefund.add(msg.value);
  }
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0) revert();
    investedAmountOf[msg.sender] = 0;
    crowdsale_eth_refund = crowdsale_eth_refund.add(weiValue);
    Refund(msg.sender, weiValue);
    if (!msg.sender.send(weiValue)) revert();
  }
  function setEndsAt(uint time) onlyOwner public {
    if(now > time) {
      revert();
    }
    endsAt = time;
    EndsAtChanged(endsAt);
  }
  function doFinalize() public inState(State.Success) onlyOwner stopInEmergency {
	if(finalized) {
      revert();
    }
	createTeamTokenByPercentage();
    token.finishMinting();	
    finalized = true;
	Finalized();
  }
}
