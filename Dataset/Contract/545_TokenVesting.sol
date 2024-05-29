contract TokenVesting is Ownable {
    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;
    ERC20Basic public token;
    struct VestingObj {
        uint256 token;
        uint256 releaseTime;
    }
    mapping (address  => VestingObj[]) public vestingObj;
    uint256 public totalTokenVested;
    event AddVesting ( address indexed _beneficiary, uint256 token, uint256 _vestingTime);
    event Release ( address indexed _beneficiary, uint256 token, uint256 _releaseTime);
    modifier checkZeroAddress(address _add) {
        require(_add != address(0));
        _;
    }
    constructor(ERC20Basic _token)
        public
        checkZeroAddress(_token)
    {
        token = _token;
    }
    function addVesting( address[] _beneficiary, uint256[] _token, uint256[] _vestingTime) 
        external 
        onlyOwner
    {
        require((_beneficiary.length == _token.length) && (_beneficiary.length == _vestingTime.length));
        for (uint i = 0; i < _beneficiary.length; i++) {
            require(_vestingTime[i] > now);
            require(checkZeroValue(_token[i]));
            require(uint256(getBalance()) >= totalTokenVested.add(_token[i]));
            vestingObj[_beneficiary[i]].push(VestingObj({
                token : _token[i],
                releaseTime : _vestingTime[i]
            }));
            totalTokenVested = totalTokenVested.add(_token[i]);
            emit AddVesting(_beneficiary[i], _token[i], _vestingTime[i]);
        }
    }
    function claim() external {
        uint256 transferTokenCount = 0;
        for (uint i = 0; i < vestingObj[msg.sender].length; i++) {
            if (now >= vestingObj[msg.sender][i].releaseTime) {
                transferTokenCount = transferTokenCount.add(vestingObj[msg.sender][i].token);
                delete vestingObj[msg.sender][i];
            }
        }
        require(transferTokenCount > 0);
        token.safeTransfer(msg.sender, transferTokenCount);
        emit Release(msg.sender, transferTokenCount, now);
    }
    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    function checkZeroValue(uint256 value) internal pure returns(bool){
        return value > 0;
    }
}
