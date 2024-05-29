contract CrowdsaleLimit {
  using SafeMath for uint256;
  uint public startsAt;
  uint public endsAt;
  uint public token_decimals = 8;
  uint public TOKEN_RATE_PRESALE  = 7200;
  uint public TOKEN_RATE_CROWDSALE= 6000;
  uint public PRESALE_TOKEN_IN_WEI = 1 ether / TOKEN_RATE_PRESALE;  
  uint public CROWDSALE_TOKEN_IN_WEI = 1 ether / TOKEN_RATE_CROWDSALE;
  uint public PRESALE_ETH_IN_WEI_FUND_MAX = 40000 ether; 
  uint public CROWDSALE_ETH_IN_WEI_FUND_MIN = 22000 ether;
  uint public CROWDSALE_ETH_IN_WEI_FUND_MAX = 90000 ether;
  uint public PRESALE_ETH_IN_WEI_ACCEPTED_MIN = 1 ether; 
  uint public CROWDSALE_ETH_IN_WEI_ACCEPTED_MIN = 100 finney;
  uint public CROWDSALE_GASPRICE_IN_WEI_MAX = 0;
  uint public presale_eth_fund= 0;
  uint public crowdsale_eth_fund= 0;
  uint public crowdsale_eth_refund = 0;
  mapping(address => uint) public team_addresses_token_percentage;
  mapping(uint => address) public team_addresses_idx;
  uint public team_address_count= 0;
  uint public team_token_percentage_total= 0;
  uint public team_token_percentage_max= 40;
  event EndsAtChanged(uint newEndsAt);
  event AddTeamAddress(address addr, uint release_time, uint token_percentage);
  event Refund(address investor, uint weiAmount);
  modifier allowCrowdsaleAmountLimit(){	
	if (msg.value == 0) revert();
	if((crowdsale_eth_fund.add(msg.value)) > CROWDSALE_ETH_IN_WEI_FUND_MAX) revert();
	if((CROWDSALE_GASPRICE_IN_WEI_MAX > 0) && (tx.gasprice > CROWDSALE_GASPRICE_IN_WEI_MAX)) revert();
	_;
  }
  function CrowdsaleLimit(uint _start, uint _end) public {
	require(_start != 0);
	require(_end != 0);
	require(_start < _end);
	startsAt = _start;
    endsAt = _end;
  }
  function calculateTokenPresale(uint value, uint decimals)   public constant returns (uint) {
    uint multiplier = 10 ** decimals;
    return value.mul(multiplier).div(PRESALE_TOKEN_IN_WEI);
  }
  function calculateTokenCrowsale(uint value, uint decimals)   public constant returns (uint) {
    uint multiplier = 10 ** decimals;
    return value.mul(multiplier).div(CROWDSALE_TOKEN_IN_WEI);
  }
  function isMinimumGoalReached() public constant returns (bool) {
    return crowdsale_eth_fund >= CROWDSALE_ETH_IN_WEI_FUND_MIN;
  }
  function addTeamAddressInternal(address addr, uint release_time, uint token_percentage) internal {
	if((team_token_percentage_total.add(token_percentage)) > team_token_percentage_max) revert();
	if((team_token_percentage_total.add(token_percentage)) > 100) revert();
	if(team_addresses_token_percentage[addr] != 0) revert();
	team_addresses_token_percentage[addr]= token_percentage;
	team_addresses_idx[team_address_count]= addr;
	team_address_count++;
	team_token_percentage_total = team_token_percentage_total.add(token_percentage);
	AddTeamAddress(addr, release_time, token_percentage);
  }
  function hasEnded() public constant returns (bool) {
    return now > endsAt;
  }
}
