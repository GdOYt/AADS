contract ECTAToken is BurnableToken {
    string public constant name = "ECTA Token";
    string public constant symbol = "ECTA";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY =  1000000000 * (10 ** uint256(decimals)); 
    uint256 public constant ADMIN_ALLOWANCE =  170000000 * (10 ** uint256(decimals));  
    uint256 public constant TEAM_VESTING_AMOUNT = 200000000 * (10 ** uint256(decimals)); 
    uint256 public constant PLATFORM_GROWTH_VESTING_AMOUNT = 130000000 * (10 ** uint256(decimals)); 
    uint256 public constant CROWDSALE_ALLOWANCE= 500000000 * (10 ** uint256(decimals)); 
    address public crowdsaleAddress; 
    address public creator; 
    address public adminAddress = 0xCF3D36be31838DA6d600B882848566A1aEAE8008;  
    constructor () public BurnableToken(){
        creator = msg.sender;
        approve(adminAddress, ADMIN_ALLOWANCE);
        totalSupply_ = INITIAL_SUPPLY;
        balances[creator] = totalSupply_ - TEAM_VESTING_AMOUNT - PLATFORM_GROWTH_VESTING_AMOUNT;
    }
    modifier onlyCreator {
      require(msg.sender == creator);
      _;
    }
    function setCrowdsaleAndVesting(address _crowdsaleAddress, address _teamVestingContractAddress, address _platformVestingContractAddress) onlyCreator external {
        require (crowdsaleAddress == address(0));
        crowdsaleAddress = _crowdsaleAddress;
        approve(crowdsaleAddress, CROWDSALE_ALLOWANCE); 
        balances[_teamVestingContractAddress] = TEAM_VESTING_AMOUNT; 
        balances[_platformVestingContractAddress] = PLATFORM_GROWTH_VESTING_AMOUNT; 
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
      require(msg.sender != creator);
      return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      require(msg.sender != creator);
      return super.transferFrom(_from, _to, _value);
    }
}
