contract Crowdsale is Ownable {
  using SafeMath for uint256;
  MRAToken public token;
  uint256 public startTime = 1507782600;
  uint256 public phase_1_Time = 1512104399;
  uint256 public phase_2_Time = 1513400399;
  uint256 public phase_3_Time = 1514782799;
  uint256 public phase_4_Time = 1516078799;
  uint256 public phase_5_Time = 1517461199;
  uint256 public endTime = 1518757199;
  address public wallet;
  uint256 public phase_1_rate = 28900;
  uint256 public phase_2_rate = 1156;
  uint256 public phase_3_rate = 760;
  uint256 public phase_4_rate = 545;
  uint256 public phase_5_rate = 328;
  uint256 public phase_6_rate = 231;
  uint256 public weiRaised;
  mapping (address => uint256) rates;
  function getRate() constant returns (uint256){
    uint256 current_time = now;
    if(current_time > startTime && current_time < phase_1_Time){
      return phase_1_rate;
    }
    else if(current_time > phase_1_Time && current_time < phase_2_Time){
      return phase_2_rate;
    }
      else if(current_time > phase_2_Time && current_time < phase_3_Time){
      return phase_3_rate;
    }
      else if(current_time > phase_3_Time && current_time < phase_4_Time){
      return phase_4_rate;
      }  
      else if(current_time > phase_4_Time && current_time < phase_5_Time){
      return phase_5_rate;
    }else{
      return phase_6_rate;
    }
  }
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  function Crowdsale() {
    wallet = msg.sender;
    token = createTokenContract();
  }
  function createTokenContract() internal returns (MRAToken) {
    return new MRAToken();
  }
  function () payable {
    buyTokens(msg.sender);
  }
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(getRate());
    weiRaised = weiRaised.add(weiAmount);
    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
 function destroy() onlyOwner {
     uint256 balance = token.balanceOf(this);
     assert (balance > 0);
     token.transfer(owner,balance);
     selfdestruct(owner);
 }
}
