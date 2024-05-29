contract DVPlock is Ownable{
  using SafeERC20 for ERC20;
  using SafeMath for uint256;
  ERC20 public token;
  address public sponsor;
  mapping (address => uint256) public balances;
  mapping (address => uint256) public withdrawAmounts;
  uint256 public tokenTotal;
  uint256 public releaseTime;
  constructor() public{
    releaseTime = 0;
    tokenTotal = 0;
    sponsor = msg.sender;    
  }
  function setToken(ERC20 _token) onlyOwner public{
    if(token!=address(0)){
      revert();
    }
    token = _token;
  }
  function setReleaseTime(uint256 _releaseTime) onlyOwner public{
      require(releaseTime==0);
      releaseTime = _releaseTime;
      require(addSponsor(sponsor));
  }
  function addSponsor(address _sponsor) internal returns(bool result){
      uint256 _amount =token.totalSupply()/5;
      return addInvestor(_sponsor,_amount);
  }
  function addInvestor(address investor,uint256 amount) onlyOwner public returns(bool result){
      if(releaseTime!=0){
          require(block.timestamp < releaseTime);
      }
      require(tokenTotal == token.balanceOf(this));
      balances[investor] = balances[investor].add(amount);
      tokenTotal = tokenTotal.add(amount);
      if(tokenTotal>token.balanceOf(this)){
          token.safeTransferFrom(msg.sender,this,amount);
      }
      return true;
  }
  function release() public {
    require(releaseTime!=0);
    require(block.timestamp >= releaseTime);
    require(balances[msg.sender] > 0);
    uint256 released_times = (block.timestamp-releaseTime).div(60*60*24*30*3); 
    uint256 _amount = 0;
    uint256 lock_quarter = 0;
    if(msg.sender!=sponsor){
        lock_quarter = 6 ;
    }else{
        lock_quarter = 12;
    }
    if(withdrawAmounts[msg.sender]==0){
        withdrawAmounts[msg.sender]= balances[msg.sender].div(lock_quarter);
    }
    if(released_times>=lock_quarter){
        _amount = balances[msg.sender];
    }else{
        _amount = balances[msg.sender].sub(withdrawAmounts[msg.sender].mul(lock_quarter.sub(released_times+1)));
    }
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    tokenTotal = tokenTotal.sub(_amount);
    token.safeTransfer(msg.sender, _amount);
  }
}
