contract CareerChainPrivateSale is TimedCrowdsale, WhitelistedCrowdsale  {
    using SafeMath for uint256;
    uint256 public tokensStillInLockup;
    uint256[6] public lockupEndTime;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public released;
    uint256 public firstVestedLockUpAmount;
    uint256 public stagedVestedLockUpAmounts;
    function CareerChainPrivateSale
        (
            uint256 _openingTime,
            uint256 _closingTime,
            uint256 _rate,
            address _wallet,
            uint256[6] _lockupEndTime,
            uint256 _firstVestedLockUpAmount,
            uint256 _stagedVestedLockUpAmounts,
            CareerChainToken _token
        )
        public
        Crowdsale(_rate, _wallet, _token)
        TimedCrowdsale(_openingTime, _closingTime)
        {
            require(_lockupEndTime[0] >= block.timestamp);
            require(_lockupEndTime[1] >= _lockupEndTime[0]);
            require(_lockupEndTime[2] >= _lockupEndTime[1]);
            require(_lockupEndTime[3] >= _lockupEndTime[2]);
            require(_lockupEndTime[4] >= _lockupEndTime[3]);
            require(_lockupEndTime[5] >= _lockupEndTime[4]);
            lockupEndTime = _lockupEndTime;
            firstVestedLockUpAmount = _firstVestedLockUpAmount;
            stagedVestedLockUpAmounts = _stagedVestedLockUpAmounts;
        }
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        uint256 newTokensSold = tokensStillInLockup.add(_tokenAmount);
        require(newTokensSold <= token.balanceOf(address(this)));
        tokensStillInLockup = newTokensSold;
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
    }
    function TransferUnsoldTokensBackToTokenContract(address _beneficiary) public onlyOwner {
        require(hasClosed());
        uint256 unSoldTokens = token.balanceOf(address(this)).sub(tokensStillInLockup);
        token.transfer(_beneficiary, unSoldTokens);
    }
    function IssueTokensToInvestors(address _beneficiary, uint256 _amount) public onlyOwner onlyWhileOpen{
        require(_beneficiary != address(0));
        _processPurchase(_beneficiary, _amount);
    }
    function _changeRate(uint256 _rate) public onlyOwner {
        require(_rate > 0);
        rate = _rate;
    }
    function releasableAmount() private view returns (uint256) {
      return vestedAmount().sub(released[msg.sender]);
    }
    function vestedAmount() private view returns (uint256) {
      uint256 lockupStage = 0;
      uint256 releasable = 0;
      uint256 i=0;
      while (i < lockupEndTime.length && lockupEndTime[i]<=now)
      {
        lockupStage = lockupStage.add(1);
        i = i.add(1);
      }
      if(lockupStage>0)
      {
        releasable = (lockupStage.sub(1).mul(stagedVestedLockUpAmounts)).add(firstVestedLockUpAmount);
      }
      return releasable;
    }
    function withdrawTokens() public {
      uint256 tobeReleased = 0;
      uint256 unreleased = releasableAmount();
      if(balances[msg.sender] >= unreleased && lockupEndTime[lockupEndTime.length-1] > now)
      {
        tobeReleased = unreleased;
      }
      else
      {
        tobeReleased = balances[msg.sender];
      }
      require(tobeReleased > 0);
      balances[msg.sender] = balances[msg.sender].sub(tobeReleased);
      tokensStillInLockup = tokensStillInLockup.sub(tobeReleased);
      released[msg.sender] = released[msg.sender].add(tobeReleased);
      _deliverTokens(msg.sender, tobeReleased);
    }
}
