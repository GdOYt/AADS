contract AMTTimelockedToken is Ownable {
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;
  uint8 public constant decimals = 18;  
  ERC20Basic token;
  uint256 public constant MANAGE_CAP = 1 * (10 ** 8) * (10 ** uint256(decimals));  
  uint256 public constant DEVELOP_CAP = 2 * (10 ** 8) * (10 ** uint256(decimals));  
  uint256 public constant MARKET_CAP = 1 * (10 ** 8) * (10 ** uint256(decimals));  
  uint256 public constant FINANCE_CAP = 6 * (10 ** 7) * (10 ** uint256(decimals));  
  uint256 public constant MANAGE_CAP_PER_ROUND = 2 * (10 ** 7) * (10 ** uint256(decimals));
  uint256 public constant DEVELOP_CAP_PER_ROUND = 4 * (10 ** 7) * (10 ** uint256(decimals));
  uint256 public constant MARKET_CAP_PER_ROUND = 2 * (10 ** 7) * (10 ** uint256(decimals));
  uint256 public constant FINANCE_CAP_PER_ROUND = 12 * (10 ** 6) * (10 ** uint256(decimals));
  mapping (address => uint256) releasedTokens;
  address beneficiary_manage;  
  address beneficiary_develop;  
  address beneficiary_market;  
  address beneficiary_finance;  
  uint256 first_round_release_time;  
  uint256 second_round_release_time;  
  uint256 third_round_release_time;  
  uint256 forth_round_release_time;  
  uint256 fifth_round_release_time;  
  constructor(
    ERC20Basic _token,
    address _beneficiary_manage,
    address _beneficiary_develop,
    address _beneficiary_market,
    address _beneficiary_finance,
    uint256 _first_round_release_time,
    uint256 _second_round_release_time,
    uint256 _third_round_release_time,
    uint256 _forth_round_release_time,
    uint256 _fifth_round_release_time
  ) public {
    token = _token;
    beneficiary_manage = _beneficiary_manage;
    beneficiary_develop = _beneficiary_develop;
    beneficiary_market = _beneficiary_market;
    beneficiary_finance = _beneficiary_finance;
    first_round_release_time = _first_round_release_time;
    second_round_release_time = _second_round_release_time;
    third_round_release_time = _third_round_release_time;
    forth_round_release_time = _forth_round_release_time;
    fifth_round_release_time = _fifth_round_release_time;
  }
  function getToken() public view returns (ERC20Basic) {
    return token;
  }
  function getBeneficiaryManage() public view returns (address) {
    return beneficiary_manage;
  }
  function getBeneficiaryDevelop() public view returns (address) {
    return beneficiary_develop;
  }
  function getBeneficiaryMarket() public view returns (address) {
    return beneficiary_market;
  }
  function getBeneficiaryFinance() public view returns (address) {
    return beneficiary_finance;
  }
  function getFirstRoundReleaseTime() public view returns (uint256) {
    return first_round_release_time;
  }
  function getSecondRoundReleaseTime() public view returns (uint256) {
    return second_round_release_time;
  }
  function getThirdRoundReleaseTime() public view returns (uint256) {
    return third_round_release_time;
  }
  function getForthRoundReleaseTime() public view returns (uint256) {
    return forth_round_release_time;
  }
  function getFifthRoundReleaseTime() public view returns (uint256) {
    return fifth_round_release_time;
  }
  function releasedTokenOf(address _owner) public view returns (uint256) {
    return releasedTokens[_owner];
  }
  function validateReleasedToken(uint256 _round) internal onlyOwner {
    uint256 releasedTokenOfManage = releasedTokens[beneficiary_manage];
    uint256 releasedTokenOfDevelop = releasedTokens[beneficiary_develop];
    uint256 releasedTokenOfMarket = releasedTokens[beneficiary_market];
    uint256 releasedTokenOfFinance = releasedTokens[beneficiary_finance];
    require(releasedTokenOfManage < MANAGE_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfManage.add(MANAGE_CAP_PER_ROUND) <= MANAGE_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfDevelop < DEVELOP_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfDevelop.add(DEVELOP_CAP_PER_ROUND) <= DEVELOP_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfMarket < MARKET_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfMarket.add(MARKET_CAP_PER_ROUND) <= MARKET_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfFinance < FINANCE_CAP_PER_ROUND.mul(_round));
    require(releasedTokenOfFinance.add(FINANCE_CAP_PER_ROUND) <= FINANCE_CAP_PER_ROUND.mul(_round));
    uint256 totalRoundCap = MANAGE_CAP_PER_ROUND.add(DEVELOP_CAP_PER_ROUND).add(MARKET_CAP_PER_ROUND).add(FINANCE_CAP_PER_ROUND);
    require(token.balanceOf(this) >= totalRoundCap);
    token.safeTransfer(beneficiary_manage, MANAGE_CAP_PER_ROUND);
    releasedTokens[beneficiary_manage] = releasedTokens[beneficiary_manage].add(MANAGE_CAP_PER_ROUND);
    token.safeTransfer(beneficiary_develop, DEVELOP_CAP_PER_ROUND);
    releasedTokens[beneficiary_develop] = releasedTokens[beneficiary_develop].add(DEVELOP_CAP_PER_ROUND);
    token.safeTransfer(beneficiary_market, MARKET_CAP_PER_ROUND);
    releasedTokens[beneficiary_market] = releasedTokens[beneficiary_market].add(MARKET_CAP_PER_ROUND);
    token.safeTransfer(beneficiary_finance, FINANCE_CAP_PER_ROUND);
    releasedTokens[beneficiary_finance] = releasedTokens[beneficiary_finance].add(FINANCE_CAP_PER_ROUND);
  }
  function releaseToken() public onlyOwner {
    if (block.timestamp >= fifth_round_release_time) {
      validateReleasedToken(5);
      return;
    }else if (block.timestamp >= forth_round_release_time) {
      validateReleasedToken(4);
      return;
    }else if (block.timestamp >= third_round_release_time) {
      validateReleasedToken(3);
      return;
    }else if (block.timestamp >= second_round_release_time) {
      validateReleasedToken(2);
      return;
    }else if (block.timestamp >= first_round_release_time) {
      validateReleasedToken(1);
      return;
    }
  }
}
