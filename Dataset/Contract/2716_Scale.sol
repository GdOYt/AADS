contract Scale is MintableToken, HasNoEther {
    using SafeMath for uint;
    string public constant name = "SCALE";
    string public constant symbol = "SCALE";
    uint8 public constant  decimals = 18;
    address public pool = address(0);
    uint public poolMintRate;
    uint public ownerMintRate;
    uint public poolMintAmount;
    uint public stakingMintAmount;
    uint public ownerMintAmount;
    uint public poolPercentage = 70;
    uint public ownerPercentage = 5;
    uint public stakingPercentage = 25;
    uint public ownerTimeLastMinted;
    uint public poolTimeLastMinted;
    uint public stakingMintRate;
    uint public totalScaleStaked;
    mapping (uint => uint) totalStakingHistory;
    uint timingVariable = 86400;
    struct AddressStakeData {
        uint stakeBalance;
        uint initialStakeTime;
    }
    mapping (address => AddressStakeData) public stakeBalances;
    uint256 inflationRate = 1000;
    uint256 public lastInflationUpdate;
    event Stake(address indexed staker, uint256 value);
    event Unstake(address indexed unstaker, uint256 stakedAmount, uint256 stakingGains);
    constructor() public {
        owner = msg.sender;
        uint _initOwnerSupply = 10000000 ether;
        bool _success = mint(msg.sender, _initOwnerSupply);
        require(_success);
        ownerTimeLastMinted = now;
        poolTimeLastMinted = now;
        poolMintAmount = _initOwnerSupply.mul(poolPercentage).div(100);
        ownerMintAmount = _initOwnerSupply.mul(ownerPercentage).div(100);
        stakingMintAmount = _initOwnerSupply.mul(stakingPercentage).div(100);
        uint _oneYearInSeconds = 31536000 ether;
        poolMintRate = calculateFraction(poolMintAmount, _oneYearInSeconds, decimals);
        ownerMintRate = calculateFraction(ownerMintAmount, _oneYearInSeconds, decimals);
        stakingMintRate = calculateFraction(stakingMintAmount, _oneYearInSeconds, decimals);
        lastInflationUpdate = now;
    }
    function adjustInflationRate() private {
      lastInflationUpdate = now;
      if (inflationRate > 100) {
        inflationRate = inflationRate.sub(300);
      }
      else if (inflationRate > 10) {
        inflationRate = inflationRate.sub(5);
      }
      poolMintAmount = totalSupply.mul(inflationRate).div(1000).mul(poolPercentage).div(100);
      ownerMintAmount = totalSupply.mul(inflationRate).div(1000).mul(ownerPercentage).div(100);
      stakingMintAmount = totalSupply.mul(inflationRate).div(1000).mul(stakingPercentage).div(100);
        poolMintRate = calculateFraction(poolMintAmount, 31536000 ether, decimals);
        ownerMintRate = calculateFraction(ownerMintAmount, 31536000 ether, decimals);
        stakingMintRate = calculateFraction(stakingMintAmount, 31536000 ether, decimals);
    }
    function updateInflationRate() public {
      require(now.sub(lastInflationUpdate) >= 31536000);
      adjustInflationRate();
    }
    function stakeScale(uint _stakeAmount) external {
        require(stake(msg.sender, _stakeAmount));
    }
    function stakeFor(address _user, uint _stakeAmount) external {
      require(stakeBalances[_user].stakeBalance == 0);
      transfer( _user, _stakeAmount);
      stake(_user, _stakeAmount);
    }
    function stake(address _user, uint256 _value) private returns (bool success) {
        require(_value <= balances[_user]);
        require(stakeBalances[_user].stakeBalance == 0);
        balances[_user] = balances[_user].sub(_value);
        stakeBalances[_user].stakeBalance = _value;
        totalScaleStaked = totalScaleStaked.add(_value);
        stakeBalances[_user].initialStakeTime = now.div(timingVariable);
        setTotalStakingHistory();
        emit Stake(_user, _value);
        return true;
    }
    function getStakingGains(uint _now) view public returns (uint) {
        if (stakeBalances[msg.sender].stakeBalance == 0) {
          return 0;
        }
        return calculateStakeGains(_now);
    }
    function unstake() external returns (bool) {
        require(stakeBalances[msg.sender].stakeBalance > 0);
        require(now.div(timingVariable).sub(stakeBalances[msg.sender].initialStakeTime) >= 7);
        uint _tokensToMint = calculateStakeGains(now);
        balances[msg.sender] = balances[msg.sender].add(stakeBalances[msg.sender].stakeBalance);
        totalScaleStaked = totalScaleStaked.sub(stakeBalances[msg.sender].stakeBalance);
        mint(msg.sender, _tokensToMint);
        emit Unstake(msg.sender, stakeBalances[msg.sender].stakeBalance, _tokensToMint);
        stakeBalances[msg.sender].stakeBalance = 0;
        stakeBalances[msg.sender].initialStakeTime = 0;
        setTotalStakingHistory();
        return true;
    }
    function calculateStakeGains(uint _now) view private returns (uint mintTotal)  {
      uint _nowAsTimingVariable = _now.div(timingVariable);     
      uint _initialStakeTimeInVariable = stakeBalances[msg.sender].initialStakeTime;  
      uint _timePassedSinceStakeInVariable = _nowAsTimingVariable.sub(_initialStakeTimeInVariable);  
      uint _stakePercentages = 0;  
      uint _tokensToMint = 0;  
      uint _lastUsedVariable;   
      for (uint i = _initialStakeTimeInVariable; i < _nowAsTimingVariable; i++) {
        if (totalStakingHistory[i] != 0) {
          _stakePercentages = _stakePercentages.add(calculateFraction(stakeBalances[msg.sender].stakeBalance, totalStakingHistory[i], decimals));
          _lastUsedVariable = totalStakingHistory[i];
        }
        else {
          _stakePercentages = _stakePercentages.add(calculateFraction(stakeBalances[msg.sender].stakeBalance, _lastUsedVariable, decimals));
        }
      }
        uint _stakePercentageAverage = calculateFraction(_stakePercentages, _timePassedSinceStakeInVariable, 0);
        uint _finalMintRate = stakingMintRate.mul(_stakePercentageAverage);
        _finalMintRate = _finalMintRate.div(1 ether);
        if (_timePassedSinceStakeInVariable >= 365) {
          _tokensToMint = calculateMintTotal(timingVariable.mul(365), _finalMintRate);
        }
        else {
          _tokensToMint = calculateMintTotal(_timePassedSinceStakeInVariable.mul(timingVariable), _finalMintRate);
        }
        return  _tokensToMint;
    }
    function setTotalStakingHistory() private {
      uint _nowAsTimingVariable = now.div(timingVariable);
      totalStakingHistory[_nowAsTimingVariable] = totalScaleStaked;
    }
    function getStakedBalance() view external returns (uint stakedBalance) {
        return stakeBalances[msg.sender].stakeBalance;
    }
    function ownerClaim() external onlyOwner {
        require(now > ownerTimeLastMinted);
        uint _timePassedSinceLastMint;  
        uint _tokenMintCount;  
        bool _mintingSuccess;  
        _timePassedSinceLastMint = now.sub(ownerTimeLastMinted);
        assert(_timePassedSinceLastMint > 0);
        _tokenMintCount = calculateMintTotal(_timePassedSinceLastMint, ownerMintRate);
        _mintingSuccess = mint(msg.sender, _tokenMintCount);
        require(_mintingSuccess);
        ownerTimeLastMinted = now;
    }
    function poolIssue() public {
        require(pool != address(0));
        require(now > poolTimeLastMinted);
        require(pool != address(0));
        uint _timePassedSinceLastMint;  
        uint _tokenMintCount;  
        bool _mintingSuccess;  
        _timePassedSinceLastMint = now.sub(poolTimeLastMinted);
        assert(_timePassedSinceLastMint > 0);
        _tokenMintCount = calculateMintTotal(_timePassedSinceLastMint, poolMintRate);
        _mintingSuccess = mint(pool, _tokenMintCount);
        require(_mintingSuccess);
        poolTimeLastMinted = now;
    }
    function setPool(address _newAddress) public onlyOwner {
        pool = _newAddress;
    }
    function calculateFraction(uint _numerator, uint _denominator, uint _precision) pure private returns(uint quotient) {
        _numerator = _numerator.mul(10 ** (_precision + 1));
        uint _quotient = ((_numerator.div(_denominator)) + 5) / 10;
        return (_quotient);
    }
    function calculateMintTotal(uint _timeInSeconds, uint _mintRate) pure private returns(uint mintAmount) {
        return(_timeInSeconds.mul(_mintRate));
    }
}
