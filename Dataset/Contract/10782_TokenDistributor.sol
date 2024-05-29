contract TokenDistributor is Ownable {
    using SafeMath for uint;
    address public targetToken;
    address[] public stakeHolders;
    uint256 public maxStakeHolders;
    event InsufficientTokenBalance( address indexed _token, uint256 _time );
    event TokensDistributed( address indexed _token, uint256 _total, uint256 _time );
    constructor ( address _targetToken, uint256 _totalStakeHolders, address[] _stakeHolders) public Ownable() {
        setTargetToken(_targetToken);
        maxStakeHolders = _totalStakeHolders;
        if (_stakeHolders.length > 0) {
            for (uint256 count = 0; count < _stakeHolders.length && count < _totalStakeHolders; count++) {
                if (_stakeHolders[count] != 0x0) {
                    _setStakeHolder(_stakeHolders[count]);
                }
            }
        }
    }
    function isDistributionDue (address _token) public view returns (bool) {
        return getTokenBalance(_token) > 1;
    }
    function isDistributionDue () public view returns (bool) {
        return getTokenBalance(targetToken) > 1;
    }
    function countStakeHolders () public view returns (uint256) {
        return stakeHolders.length;
    }
    function getTokenBalance(address _token) public view returns (uint256) {
        ERC20Basic token = ERC20Basic(_token);
        return token.balanceOf(address(this));
    }
    function getPortion (uint256 _total) public view returns (uint256) {
        return _total.div(stakeHolders.length);
    }
    function setTargetToken (address _targetToken) public onlyOwner returns (bool) {
        if(_targetToken != 0x0 && targetToken == 0x0) {
          targetToken = _targetToken;
          return true;
        }
    }
    function _setStakeHolder (address _stakeHolder) internal onlyOwner returns (bool) {
        require(countStakeHolders() < maxStakeHolders, "Max StakeHolders set");
        stakeHolders.push(_stakeHolder);
        return true;
    }
    function _transfer (address _token, address _recipient, uint256 _value) internal {
        ERC20Basic token = ERC20Basic(_token);
        token.transfer(_recipient, _value);
    }
    function distribute (address _token) public returns (bool) {
        uint256 balance = getTokenBalance(_token);
        uint256 perStakeHolder = getPortion(balance);
        if (balance < 1) {
            emit InsufficientTokenBalance(_token, block.timestamp);
            return false;
        } else {
            for (uint256 count = 0; count < stakeHolders.length; count++) {
                _transfer(_token, stakeHolders[count], perStakeHolder);
            }
            uint256 newBalance = getTokenBalance(_token);
            if (newBalance > 0 && getPortion(newBalance) == 0) {
                _transfer(_token, owner, newBalance);
            }
            emit TokensDistributed(_token, balance, block.timestamp);
            return true;
        }
    }
    function () public {
        distribute(targetToken);
    }
}
